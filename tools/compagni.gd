extends SceneTree
## Roadmap 32 (voci 313 e 318): la misura dei compagni di battaglia → prove/compagni.txt.
##   1. la creatura «tipica» di ogni zona (media pesata delle specie dello strato, cresciute con lo strato e il vigore) e
##      il suo «livello» (`BondsData.level_of`): a che livello un compagno la pareggia;
##   2. un compagno di ogni livello contro la creatura tipica della zona del suo livello: quanti colpi le servono, quanti
##      ne regge, chi vince in un duello da solo (contatto ogni `HIT_EVERY` secondi, ferite ogni 0,9 s);
##   3. la forma delle specie: Vita, danno e difesa al livello 1, 25 e 50 di alcune specie molto diverse;
##   4. quante creature servono per salire di livello (alla pari, contro creature del suo livello).
## Uso: Godot_console.exe --headless --path . --script res://tools/compagni.gd

const ZONES := [["Sup v1", 0, 1], ["Sott v1", 1, 1], ["Cav v1", 2, 1], ["Prof v1", 3, 1], ["Fondo v1", 4, 1],
	["Cav v2", 2, 2], ["Fondo v2", 4, 2], ["Fondo v3", 4, 3], ["Fondo v5", 4, 5], ["Fondo v8", 4, 8], ["Fondo v12", 4, 12]]
const SPECIES := ["grumo_muschio", "pecora_muschio", "volpe_ambra", "sputaspore", "lupo_lunare", "talpone",
	"falena_brace", "anguilla_linfa"]


func _init() -> void:
	var out := PackedStringArray()
	out.append("COMPAGNI DI BATTAGLIA (Roadmap 32) — crescita %.3f a livello, livello massimo %d" % [BondsData.GROWTH, BondsData.LVL_MAX])
	out.append("")
	out.append("1. LA CREATURA TIPICA DI OGNI ZONA (Vita, danno, difesa) e il suo livello")
	var zone_lvl := {}
	for z in ZONES:
		var t := _typical(int(z[1]), int(z[2]))
		var lv := BondsData.level_of(int(t[0]), int(t[1]), int(t[2]))
		zone_lvl[z[0]] = [lv, t]
		out.append("  %-10s Vita %5d  danno %4d  difesa %3d   → livello %.1f" % [z[0], t[0], t[1], t[2], lv])
	out.append("")
	out.append("2. UN COMPAGNO (volpe d'ambra, forza 1, doti normali) CONTRO LA CREATURA TIPICA, DA SOLO")
	out.append("  livello | zona alla pari | colpi per abbatterla | colpi che regge | secondi | vince")
	for z in ZONES:
		var lv := roundi(float(zone_lvl[z[0]][0]))
		var t: Array = zone_lvl[z[0]][1]
		var st := BondsData.stats("volpe_ambra", lv, 1.0, 1.0, 1.0, {}, {})
		var hit_out := maxi(int(st["damage"]) - int(t[2]) / 2, 1)
		var hit_in := maxi(roundi(float(t[1]) * DangerData.DAMAGE) - int(st["defense"]) / 2, 1)
		var need := ceili(float(t[0]) / hit_out)
		var bear := ceili(float(st["hp"]) / hit_in)
		var secs := need * BondsData.HIT_EVERY
		var win := need * BondsData.HIT_EVERY <= bear * 0.9
		out.append("  %7d | %-14s | %20d | %15d | %7.1f | %s" % [lv, z[0], need, bear, secs, "sì" if win else "no"])
	out.append("")
	out.append("3. LA FORMA DELLE SPECIE (Vita / danno / difesa) al livello 1, 25 e 50")
	for sp in SPECIES:
		var row := "  %-16s k %.2f" % [sp, BondsData.species_k(sp)]
		for lv in [1, 25, 50]:
			var st := BondsData.stats(sp, lv, 1.0, 1.0, 1.0, {}, {})
			row += " | L%d %5d / %4d / %3d" % [lv, st["hp"], st["damage"], st["defense"]]
		out.append(row)
	out.append("")
	out.append("4. CREATURE PER SALIRE DI LIVELLO (contro creature del suo stesso livello)")
	var tot := 0
	var row4 := "  "
	for lv in range(1, BondsData.LVL_MAX):
		var n := ceili(float(BondsData.xp_for(lv)) / BondsData.xp_from(float(lv), lv))
		tot += n
		if lv in [1, 5, 10, 20, 30, 40, 49]:
			row4 += "L%d→%d: %d   " % [lv, lv + 1, n]
	out.append(row4)
	out.append("  in tutto, dal livello 1 al %d: %d creature alla pari (metà dell'esperienza quando le sconfigge il Germogliato)" % [BondsData.LVL_MAX, tot])
	var f := FileAccess.open("res://prove/compagni.txt", FileAccess.WRITE)
	f.store_string("\n".join(out) + "\n")
	print("\n".join(out))
	quit()


## La creatura tipica di uno strato a un vigore: media pesata di Vita, danno e difesa, cresciute come in `Fauna`.
func _typical(stratum: int, vigor: int) -> Array:
	var w := 0.0
	var hp := 0.0
	var dmg := 0.0
	var df := 0.0
	CreaturesData.now_vigor = vigor
	for e in CreaturesData.of_stratum(stratum, false, "foresta" if stratum == 0 else ""):
		var d := CreaturesData.get_data(String(e[0]))
		if d.get("boss", false) or d.get("docile", false):
			continue
		var k := float(e[1])
		hp += float(d["hp"]) * k
		dmg += float(d["damage"]) * k
		df += float(d.get("defense", 0)) * k
		w += k
	var mult := float(StrataData.STRATA[stratum]["danger"]) * VigorData.creature_mult(vigor)
	w = maxf(w, 1.0)
	return [roundi(hp / w * mult), roundi(dmg / w * mult), roundi(df / w)]
