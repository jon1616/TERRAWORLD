class_name MbParafulmine
extends MachineBehavior
## Il Parafulmine di radice: non dà pulsi di continuo; durante i temporali `Weather.strike` manda il fulmine su di lui
## (`Energy.bolt_target`) e ogni fulmine versa le sue gocce nelle riserve della rete (`Energy.on_bolt`).


func state_text(mc: Machine, e: Energy) -> String:
	var n := int(mc.st.get("colpi", 0))
	var t := "aspetta i temporali"
	if e.m.get("weather") != null and String(e.m.weather.id) == "temporale":
		t = "c'è un temporale: attira i fulmini"
	if mc.net < 0 or (e.nets[mc.net]["reserves"] as Array).is_empty():
		t += " (serve una riserva sulla sua rete)"
	return t + ("; fulmini presi: %d" % n if n > 0 else "")
