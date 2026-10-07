class_name TestsTrade
extends RefCounted
## Il commercio e gli abitanti (Roadmap 48, voce 404). Gruppo «commercio».
## Le voci dei negozi (più di mille, secondo fase, stagione, notte ed evento), le pagine del commercio, le merci della
## fascia del mondo che cambiano con il vigore, il Mercante dei mondi con le merci che cambiano ogni giorno.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	await panel()
	print("commercio: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: il commercio non va come dovrebbe")


func data() -> void:
	var low := ShopsData.extra("forgiatore", 1, -1, false, false)
	var high := ShopsData.extra("forgiatore", 12, -1, false, false)
	var night := ShopsData.extra("forgiatore", 1, 2, true, true)
	var d1 := ShopsData.rotating(1)
	var d2 := ShopsData.rotating(2)
	var uniques := 0
	for e in d1:
		if String(e[0]).begins_with("merce_unica_"):
			uniques += 1
	var price := ValueData.buy_price(String(ShopsData.MERCHANT["uniques"][0]), 1)
	res["dati"] = ShopsData.count() >= 1100 and low != high and night.size() > low.size() and d1 != d2 \
		and uniques == ShopsData.ROT_UNIQUE and price >= 1000
	print("commercio, i dati: %d voci in più nei negozi; forgiatore al vigore 1 «%s», al 12 «%s»; Mercante oggi %d merci (%d sue), la prima unica costa %d Lumini" % [
		ShopsData.count(), low[0][0], high[0][0], d1.size(), uniques, price])


## Il pannello del commercio va a pagine.
func panel() -> void:
	var tp: TradePanel = m.villagers.panel
	tp.m = m
	tp.open("forgiatore")
	await kit.frames(2)
	var n: int = tp.pages()
	tp.turn(1)
	var p1: int = tp.page
	tp.turn(-5)
	var p0: int = tp.page
	tp.close()
	res["pagine"] = n >= 2 and p1 == 1 and p0 == 0
	print("commercio, il Forgiatore: %d pagine di merci, avanti %d, indietro %d" % [n, p1, p0])
