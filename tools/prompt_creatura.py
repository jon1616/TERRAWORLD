# -*- coding: utf-8 -*-
"""Il generatore dei prompt di Nano Banana per le pose delle creature (8 ott 2026, richiesta dell'utente: «il generatore
di prompt più preciso e dettagliato possibile»).

Legge la scheda della creatura (`tools/scheda_creatura.gd`: dati, piano del corpo, comportamenti, famiglia, dove vive,
misura e colori del disegno di oggi) e il suo aspetto scritto a mano (`arte_ia/creature/aspetti.json`, in inglese:
come deve essere, perché i disegni del codice sono spesso troppo rozzi per copiarli), sceglie le pose che il gioco
userà davvero (dai comportamenti: chi cammina, chi vola, chi salta, chi carica, chi spara, chi bruca, chi scappa, la
furia dei boss) e scrive:
  arte_ia/creature/prompt/<id>.txt   il prompt, già copiato negli appunti di Windows
  arte_ia/creature/prompt/<id>.json  la ricetta per `tools/installa_creatura.py` (griglia, pose, misura, colori)

Uso:  python tools/prompt_creatura.py spinoriccio          (rifà la scheda se manca: --scheda per rifarla sempre)
      python tools/prompt_creatura.py --prossima            la prima creatura della coda senza pose
      python tools/prompt_creatura.py spinoriccio --no-appunti
"""
import argparse
import colorsys
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT = r"C:\Users\Principale\Desktop\GODOT\Godot_v4.6.1-stable_win64_console.exe"
CREATURE = os.path.join(ROOT, "arte_ia", "creature")
SCHEDE = os.path.join(CREATURE, "schede")
PROMPT = os.path.join(CREATURE, "prompt")
ASPETTI = os.path.join(CREATURE, "aspetti.json")
POSES_DATA = os.path.join(ROOT, "src", "data", "creature_poses_data.gd")

STYLE = ("[STYLE SHEET «Roots and Sap»] Side-view pixel-art game creature for a 2D side-scrolling game, organic "
         "hand-crafted look, a dark deep world where light comes from living things (amber, glowing sap, embers), "
         "NOT Terraria, NOT cute chibi, NOT 3D, NOT realistic painting.")
RULES = ("Draw it LARGE with big clear shapes and flat colours: it will be pixelated later by a script to about {px} "
         "pixels wide, so every detail must be BIG and readable at that size (no thin lines, no tiny details, no "
         "texture noise, no soft gradients, at most 2-3 tones per colour). No shadows on the ground, NO ground line, "
         "no dust clouds, no motion blur, no speed lines, no sparkles around the creature, no text, no numbers, no letters, no grid lines, no frames, no borders.")
GRID = ("Solid flat magenta #FF00FF background everywhere. EXACTLY {rows} rows and 4 columns: {n} equal cells, "
        "NO extra row, NO extra copies, ONE {noun} per cell, ALWAYS facing RIGHT (head on the right), ALWAYS the same "
        "size and the same colours in every cell. {anchor}")
ANCHOR_GROUND = "In every cell the feet (or belly) touch the same ground line near the bottom of the cell, except the poses that are explicitly in the air."
ANCHOR_AIR = "The body is always centred in its cell, at the same height; only wings, limbs and tail move."
OUTLINE = "A thick very dark outline (almost black) all around the creature, one clean line."
PROFILE = ("EVERY cell shows the creature strictly in PROFILE (side view, as in a side-scrolling game), head on the "
           "RIGHT: never seen from above, never from below, never from the front, never facing the viewer.")

# ---------------------------------------------------------------------------------------------------------- i colori

HUES = [(15, "red"), (35, "orange"), (50, "amber"), (65, "yellow"), (90, "olive green"), (150, "green"),
        (175, "teal"), (190, "turquoise"), (205, "cyan blue"), (240, "blue"), (265, "indigo"), (360, "red")]


def color_name(hexc: str) -> str:
    r, g, b = (int(hexc[i:i + 2], 16) / 255 for i in (1, 3, 5))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    deg = h * 360
    if s < 0.18 or l < 0.08:
        base = "near-black" if l < 0.12 else ("dark grey" if l < 0.35 else ("grey" if l < 0.65 else "pale grey"))
        return base
    if 20 <= deg <= 45 and l < 0.45:
        base = "brown" if l < 0.3 else "warm brown"
    elif 45 < deg <= 60 and l > 0.75:
        base = "cream"
    else:
        base = next(n for lim, n in HUES if deg <= lim)
    pre = "very dark " if l < 0.2 else ("dark " if l < 0.38 else ("light " if l > 0.7 else ""))
    return pre + base


def is_magenta_risk(hexc: str) -> bool:
    """Viola, rosa e magenta spariscono con lo sfondo: nei prompt diventano indaco-blu (la regola del magenta)."""
    r, g, b = (int(hexc[i:i + 2], 16) / 255 for i in (1, 3, 5))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return 270 <= h * 360 <= 345 and s > 0.25 and l > 0.15


def to_indigo(hexc: str) -> str:
    r, g, b = (int(hexc[i:i + 2], 16) / 255 for i in (1, 3, 5))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    r, g, b = colorsys.hls_to_rgb(232 / 360, l, s)
    return "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))


def lum(hexc: str) -> float:
    r, g, b = (int(hexc[i:i + 2], 16) for i in (1, 3, 5))
    return 0.3 * r + 0.59 * g + 0.11 * b


# ------------------------------------------------------------------------------------------------- piani e pose

PLAN_NOUN = {"bipede": "figure", "quadrupede": "animal", "uccello": "bird", "insetto": "insect", "lumaca": "snail", "anfibio": "amphibian",
             "serpe": "serpent", "fluttuante": "floating creature", "grumo": "blob"}

WALK = {
    "quadrupede": ["walking cycle 1/4: front leg forward, back leg back", "walking cycle 2/4: legs passing under the body",
                   "walking cycle 3/4: the other front leg forward", "walking cycle 4/4: legs passing again"],
    "anfibio": ["crawling cycle 1/4: front leg reaching forward", "crawling cycle 2/4: legs gathered under the body",
                "crawling cycle 3/4: back leg pushing", "crawling cycle 4/4: legs gathered again"],
    "insetto": ["walking cycle 1/4: legs in a wide stance", "walking cycle 2/4: middle legs forward",
                "walking cycle 3/4: front and back legs forward", "walking cycle 4/4: legs together"],
    "lumaca": ["gliding cycle 1/4: body stretched long", "gliding cycle 2/4: a wave in the middle of the foot",
               "gliding cycle 3/4: body pulled shorter", "gliding cycle 4/4: stretching again, head reaching forward"],
    "serpe": ["slithering cycle 1/4: body in an S curve", "slithering cycle 2/4: the curves move back",
              "slithering cycle 3/4: the opposite S curve", "slithering cycle 4/4: the curves move back again"],
    "bipede": ["walking cycle 1/4: front leg forward, arms swinging", "walking cycle 2/4: legs passing under the body",
               "walking cycle 3/4: the other leg forward", "walking cycle 4/4: legs passing again"],
    "grumo": ["hopping-in-place cycle 1/4: relaxed", "2/4: slightly squashed", "3/4: slightly stretched up",
              "4/4: relaxed again"],
}
WINGS = ["flying cycle 1/4: wings fully UP above the body", "flying cycle 2/4: wings half down",
         "flying cycle 3/4: wings fully DOWN below the body", "flying cycle 4/4: wings half up again"]
FLOAT = ["floating cycle 1/4: rising a little, tendrils/fins trailing down", "floating cycle 2/4: at the top, spread out",
         "floating cycle 3/4: sinking a little, tendrils/fins lifted", "floating cycle 4/4: at the bottom, gathered"]

SHOOTERS = {"spara", "spine", "raggio", "pioggia", "onda", "raffica", "ventaglio", "bombarda", "folgore", "evoca",
            "richiamo", "scoppia"}
JUMPERS = {"salta_verso", "molla", "balzo", "tonfo"}
CHARGERS = {"carica", "rotola"}
DASHERS = {"scatto", "picchiata", "zigzag"}
ELEM_SHOT = {"brace": "a burst of glowing embers", "gelo": "sharp ice shards", "linfa": "glowing turquoise sap drops",
             "spore": "a puff of glowing spores", "vuoto": "dark void orbs with a pale rim", "fulmine": "crackling sparks",
             "luce": "bright light motes", "ombra": "dark shadow blobs", "veleno": "green venom drops",
             "pietra": "small stone chips", "vento": "swirling wind gusts"}


def walker_plan(s: dict, look: dict) -> str:
    if look.get("plan"):
        return look["plan"]
    body = s.get("body") if isinstance(s.get("body"), dict) else {}
    if body.get("plan"):
        return body["plan"]
    if s["shape"] == "grumo" or "salta_verso" in s["behaviors"] and not s["fly"]:
        return "grumo" if s["shape"] == "grumo" else "quadrupede"
    return "uccello" if s["fly"] else "quadrupede"


def build_poses(s: dict, look: dict) -> tuple[list, dict, dict, bool]:
    """Le celle della tavola: [(nome della posa, descrizione)], le pose del gioco {nome: [celle]}, i fps, il centro."""
    beh = set(s["behaviors"]) | set(s.get("fury") or [])
    plan = walker_plan(s, look)
    shot = look.get("shot") or ELEM_SHOT.get(s.get("elem") or str((s.get("p") or {}).get("shot_look", "")),
                                               "a burst of glowing projectiles")
    boss = s["boss"] or s["chief"] or s["lord"] or s["great"]
    cells: list[tuple[str, str]] = []
    center = bool(s["fly"])
    if s["fly"]:
        cyc = FLOAT if plan == "fluttuante" else WINGS
        cells += [("vola", t) for t in cyc]
        cells.append(("sospeso", "hovering in place, wings (or fins) spread, calm, looking right"))
        cells.append(("planata", "gliding downward, wings spread wide and still, body tilted slightly nose-down"))
        if beh & DASHERS:
            cells.append(("carica", "about to dive: wings pulled back tight, body crouched, head low, staring at the prey"))
            cells.append(("scatto", "diving / dashing forward: body stretched long and straight, wings swept back"))
    elif "fermo" in beh or "agguato" in beh and "cammina" not in beh:
        # chi non si muove (funghi, piante, torrette): il respiro, il gonfiarsi prima del colpo, il colpo
        cells.append(("fermo", "resting, relaxed, breathing"))
        cells.append(("fermo", "breathing in: slightly swollen and taller"))
        cells.append(("fermo", "breathing out: slightly smaller and lower"))
        if beh & SHOOTERS:
            cells.append(("sputa", "about to shoot: swollen, glowing parts brighter, bracing"))
            cells.append(("sputa", "shooting: bursting open, firing %s upward and forward" % shot))
        cells.append(("fermo", "idle variant: swaying slightly to one side"))
    else:
        jumper = bool(beh & JUMPERS) and plan in ("grumo", "anfibio") or "salta_verso" in beh
        if jumper:
            cells.append(("fermo", "standing still, relaxed, breathing"))
            cells.append(("fermo", "idle variant: a little wider and lower (breathing out), eyes half closed"))
            cells.append(("carica", "crouching before the jump: squashed low and wide, eyes on the target"))
            cells.append(("stacco", "take-off: stretched tall and narrow, leaving the ground, leaning forward"))
            legless = plan in ("grumo", "lumaca", "serpe", "fluttuante")
            cells.append(("aria", "in the air at the top of the jump: compact and round, %s, lifted HIGH in the cell"
                          % ("NO legs (it has none)" if legless else "legs tucked")))
            cells.append(("discesa", "falling: stretched slightly downward, %s, lifted a little"
                          % ("NO legs (it has none), its bottom reaching for the ground" if legless else "legs reaching for the ground")))
            cells.append(("atterra", "landing: squashed very flat and wide on the ground, wobbling"))
        else:
            cells += [("cammina", t) for t in WALK.get(plan, WALK["quadrupede"])]
            cells.append(("fermo", "standing still, relaxed, head up, breathing"))
            if beh & CHARGERS:
                if s["roll"]:
                    cells.append(("carica", "about to roll: hunched, tucking its head in, spikes/armour raised"))
                    cells.append(("scatto", "rolled up into a tight round ball (it rolls like a wheel), only its armour/spikes visible, PERFECTLY ROUND, the ball resting on the same ground line"))
                    center = False
                else:
                    cells.append(("carica", "preparing to charge: head down, front foot scraping the ground, back legs bent"))
                    cells.append(("scatto", "charging: body stretched long and low, legs spread in a gallop, head forward"))
            if "fugge" in beh:
                cells.append(("corsa", "running away fast: body stretched, legs spread front and back in a leap"))
            elif "ladro" in beh:
                cells.append(("corsa", "running away fast with a small stolen shiny trinket in its mouth: body stretched low, legs spread in a leap"))
            if s["docile"] or s.get("role") == "erbivoro":
                cells.append(("bruca", "eating: head lowered to the ground, nibbling a small green leaf"))
        if "guscio" in beh:
            cells.append(("guscio", "withdrawn into its shell/armour, only the shell visible, still"))
    if beh & SHOOTERS and "sputa" not in [c[0] for c in cells]:
        cells.append(("sputa", "attacking: head raised, mouth (or its glowing organ) wide open, firing %s" % shot))
    cells.append(("colpita", look.get("hurt") or "hurt: flinching back, squeezed, eyes shut (if it has eyes)"))
    # le pose che mancano per riempire la griglia: altre del respiro e dell'attenzione
    fillers = [("allerta", "alert: standing taller, head raised, looking right, tense"),
               ("fermo", "idle variant: blinking, head slightly turned")]
    if "fermo" in beh:
        fillers = [("fermo", "idle variant: tilted slightly to the other side")]
    if s["fly"]:
        # chi vola non sta mai fermo: le celle in più sono un secondo tempo della posa sospesa (il ciclo del volo sul posto)
        fillers = [("sospeso", "hovering variant: wings (or fins) slightly LOWER than in the other hovering pose")]
    n = 8 if len(cells) <= 8 and not boss else 12
    if boss:
        fury = [("furia_fermo", "ENRAGED standing: the same creature, but its glowing parts blaze much brighter, eyes burning")]
        if "sputa" in [c[0] for c in cells]:
            fury.append(("furia_sputa", "ENRAGED attack: firing a much bigger %s, glowing parts blazing" % shot))
        if "scatto" in [c[0] for c in cells]:
            fury.append(("furia_carica", "ENRAGED, preparing to charge, glowing parts blazing"))
            fury.append(("furia_scatto", "ENRAGED charge, a trail of sparks behind, glowing parts blazing"))
        if "vola" in [c[0] for c in cells]:
            fury.append(("furia_vola", "ENRAGED flying, wings fully up, glowing parts blazing"))
        hurt = cells[-1]                       # «colpita» resta sempre: si tolgono le pose in più prima di lei
        cells = cells[:-1][:11 - len(fury)] + [hurt] + fury
    for f in fillers:
        if len(cells) >= n:
            break
        cells.append(f)
    while len(cells) < n:
        cells.append(fillers[-1] if s["fly"] else ("fermo", "idle variant: breathing, slightly different from the other idle pose"))
    cells = cells[:n]
    poses: dict = {}
    for i, (name, _) in enumerate(cells):
        poses.setdefault(name, []).append(i)
    fps = {}
    for name, idx in poses.items():
        if len(idx) > 1:
            fps[name] = {"vola": 11.0, "cammina": 6.0, "corsa": 10.0, "fermo": 1.6, "sospeso": 8.0}.get(name, 6.0)
    if "vola" in poses and "furia_vola" in poses:
        poses["furia_vola"] = poses["furia_vola"] + [poses["vola"][1], poses["vola"][2], poses["vola"][3]]
        fps["furia_vola"] = 11.0
    return cells, poses, fps, center


# ------------------------------------------------------------------------------------------------------ il prompt

def describe(s: dict, look: dict) -> tuple[str, list[str], list[str]]:
    """Il corpo della creatura in parole: l'aspetto scritto a mano se c'è, poi i colori con i loro codici."""
    pal = [c for c in s["palette"] if lum(c) > 18]
    glow = [c for c in s.get("glow_cols", []) if lum(c) > 60]
    notes = []
    # con i colori scritti a mano si controllano quelli (la scheda ha i colori vecchi del disegno del codice)
    given = re.findall(r"#[0-9a-fA-F]{6}", " ".join(str(look.get(k, "")) for k in ("colors", "glow", "eye")))
    risky = [c for c in (given if given else pal + glow) if is_magenta_risk(c)]
    if risky:
        notes.append("NO purple, NO pink, NO magenta anywhere (they vanish on the background): use indigo-blue instead.")
        pal = [to_indigo(c) if is_magenta_risk(c) else c for c in pal]
        glow = [to_indigo(c) if is_magenta_risk(c) else c for c in glow]
    cols = look.get("colors") or ", ".join("%s (%s)" % (color_name(c), c) for c in pal[:6])
    text = look.get("look", "")
    if not text:
        body = s.get("body") if isinstance(s.get("body"), dict) else {}
        plan = walker_plan(s, look)
        noun = PLAN_NOUN.get(plan, "creature")
        bits = ["%s %s" % ("an" if noun[0] in "aeiou" else "a", noun)]
        if body.get("horns"):
            bits.append("with %s horns" % ("short" if body["horns"] == 1 else "branching"))
        if body.get("marks"):
            bits.append("with %s on its back" % {"macchie": "spots", "strisce": "stripes", "punte": "spikes"}.get(body["marks"], body["marks"]))
        if body.get("tail"):
            bits.append("a long tail")
        text = " ".join(bits) + "."
    glow_txt = ""
    if s["glow"] or glow:
        glow_txt = (" Its glowing parts (%s) shine like little lights in the dark: make them BIG, bright and clearly "
                    "separate." % (look.get("glow") or ", ".join("%s (%s)" % (color_name(c), c) for c in glow[:3]) or "its eyes and marks"))
    eye = look.get("eye") or "one round bright eye, clearly visible, a different colour from the body"
    return "%s Colours: %s. Eyes: %s.%s" % (text, cols, eye, glow_txt), notes, glow


BIOME_EN = {"foresta": "lantern forest", "palude": "swamp", "ambra": "amber woods", "brina": "frost lands",
            "brace": "ember lands", "avvizzito": "withered blight", "deserto": "dunes", "fungaia": "mushroom groves"}


def where(s: dict) -> str:
    st = {0: "the surface forests", 1: "the root undergrowth caves", 2: "the slate caverns", 3: "the sap depths",
          4: "the bottom of the world"}
    places = [st[x] for x in s.get("strata", []) if x in st]
    if s.get("sky"):
        places.append("the floating sky islands")
    if s.get("water"):
        places.append("lakes and pools")
    out = "It lives in %s" % (", ".join(places) if places else "the wild")
    if s.get("biomes"):
        out += " (%s)" % ", ".join(BIOME_EN.get(b, b) for b in s["biomes"])
    if s.get("night"):
        out += ", only at night"
    return out + "."


def temper(s: dict) -> str:
    beh = set(s["behaviors"])
    if s["boss"] or s["chief"]:
        return "It is a BOSS: large, imposing, ancient, scarred, unmistakable at a glance."
    if s["docile"]:
        return "It is gentle and harmless unless provoked: soft round shapes, calm eyes."
    if "fugge" in beh:
        return "It is shy and quick, always ready to run: light body, alert eyes."
    if beh & (CHARGERS | SHOOTERS | DASHERS) or s.get("role") == "predatore":
        return "It is aggressive: sharp shapes, a fierce eye."
    return "It is a wild creature of this world."


def build(s: dict, look: dict) -> tuple[str, dict]:
    cells, poses, fps, center = build_poses(s, look)
    rows = len(cells) // 4
    plan = walker_plan(s, look)
    noun = look.get("noun") or PLAN_NOUN.get(plan, "creature")
    px = max(18, round(s["w"] * float(look.get("scale", 1.25))))
    body, notes, glow = describe(s, look)
    name_en = look.get("name_en") or s["name"]
    lines = [STYLE,
             'This is the "%s" (%s). %s %s' % (name_en, s["name"], temper(s), where(s)),
             RULES.format(px=px),
             GRID.format(rows=rows, n=len(cells), noun=noun, anchor=ANCHOR_AIR if center and s["fly"] else ANCHOR_GROUND),
             PROFILE,
             "The creature: " + body,
             OUTLINE]
    if look.get("extra"):
        lines.append(look["extra"])
    lines += notes
    lines.append("Keep the SAME design in every cell: same proportions, same colours, same eye, same markings; only "
                 "the pose changes. Every pose must read clearly as a silhouette.")
    for r in range(rows):
        row = ["%d %s" % (r * 4 + i + 1, cells[r * 4 + i][1]) for i in range(4)]
        lines.append("Row %d: %s." % (r + 1, "; ".join(row)))
    prompt = "\n".join(lines)
    # la ricetta per l'installatore
    # la chiave è la forma solo per la variante 0 senza ritocchi; le altre varianti di colore, i capi e chi ha
    # «art_mods» hanno un disegno tutto loro (altrimenti sovrascriverebbero quello della forma)
    key = s["id"] if (s.get("art_mods") or s["boss"] or s["chief"] or int(s.get("variant", 0)) != 0) else s["shape"]
    pal = s["palette"]
    dark = sum(lum(c) for c in pal) / max(len(pal), 1) < 70
    # chiari e poco saturi come la polvere (lo stesso controllo di `importa_creatura.py --togli-polvere`): niente filtro
    def _dusty(c: str) -> bool:
        v = [int(c[i:i + 2], 16) for i in (1, 3, 5)]
        return lum(c) > 120 and max(v) - min(v) < 70
    pale = any(_dusty(c) for c in pal + [x for x in (look.get("accents") or [])])
    accents = [c for c in (look.get("accents") or [])] or [c for c in glow[:3]]
    misura = poses.get("fermo", poses.get("sospeso", poses.get("vola", [0])))[0]
    recipe = {"id": s["id"], "key": key, "name": s["name"], "grid": "4x%d" % rows, "n": len(cells),
              "cells": [c[0] for c in cells], "poses": poses, "fps": fps, "center": center and bool(s["fly"]),
              "roll_center": bool(s["roll"]), "fly": bool(s["fly"]), "lungo": px - 2, "misura_da": misura,
              "accenti": accents, "luce": glow[:3] if s["glow"] else [], "togli_polvere": bool(look.get("polvere", not pale)),
              "schiarisci": 1.35 if dark else 1.0, "glow": bool(s["glow"])}
    return prompt, recipe


def scheda(cid: str, again: bool) -> dict:
    path = os.path.join(SCHEDE, cid + ".json")
    if again or not os.path.exists(path):
        subprocess.run([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/scheda_creatura.gd", "--", cid],
                       capture_output=True, timeout=180)
    if not os.path.exists(path):
        sys.exit("ATTENZIONE: nessuna scheda per %s" % cid)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def done_keys() -> set:
    with open(POSES_DATA, encoding="utf-8") as f:
        return set(re.findall(r'^\t"(\w+)": \{"n"', f.read(), re.M))


def next_id() -> str:
    path = os.path.join(SCHEDE, "coda.json")
    if not os.path.exists(path):
        subprocess.run([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/scheda_creatura.gd", "--", "--coda"],
                       capture_output=True, timeout=180)
    with open(path, encoding="utf-8") as f:
        rows = json.load(f)
    done = done_keys()
    skip = set(load_aspetti().get("_salta", []))
    for r in rows:
        if r["id"] in done or r["shape"] in done and int(r["variant"]) == 0 or r["id"] in skip:
            continue
        return r["id"]
    sys.exit("Tutte le creature della coda hanno le pose.")


def load_aspetti() -> dict:
    if not os.path.exists(ASPETTI):
        return {}
    with open(ASPETTI, encoding="utf-8") as f:
        return json.load(f)


def clipboard(text: str) -> None:
    tmp = os.path.join(PROMPT, "_appunti.txt")
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text)
    subprocess.run(["powershell", "-NoProfile", "-Command",
                    "Get-Content -Raw -Encoding UTF8 '%s' | Set-Clipboard" % tmp], capture_output=True)


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")       # le virgolette «» e le frecce nella console di Windows
    ap = argparse.ArgumentParser()
    ap.add_argument("id", nargs="?")
    ap.add_argument("--prossima", action="store_true")
    ap.add_argument("--scheda", action="store_true", help="rifà la scheda anche se c'è")
    ap.add_argument("--no-appunti", action="store_true")
    args = ap.parse_args()
    os.makedirs(PROMPT, exist_ok=True)
    cid = next_id() if args.prossima or not args.id else args.id
    s = scheda(cid, args.scheda)
    look = load_aspetti().get(cid, {})
    if not look:
        print("ATTENZIONE: %s non ha un aspetto scritto in aspetti.json (il prompt usa solo i dati)" % cid)
    prompt, recipe = build(s, look)
    with open(os.path.join(PROMPT, cid + ".txt"), "w", encoding="utf-8") as f:
        f.write(prompt)
    with open(os.path.join(PROMPT, cid + ".json"), "w", encoding="utf-8") as f:
        json.dump(recipe, f, ensure_ascii=False, indent=1)
    if not args.no_appunti:
        clipboard(prompt)
        with open(os.path.join(PROMPT, "_attesa.txt"), "w", encoding="utf-8") as f:
            f.write(cid)                          # la creatura che l'installatore aspetta
    print("creatura: %s (%s), %d pose in %s: %s" % (cid, s["name"], recipe["n"], recipe["grid"],
                                                    ", ".join(recipe["cells"])))
    print("prompt: arte_ia/creature/prompt/%s.txt%s" % (cid, "" if args.no_appunti else " (negli appunti)"))
    print("-" * 60)
    print(prompt)


if __name__ == "__main__":
    main()
