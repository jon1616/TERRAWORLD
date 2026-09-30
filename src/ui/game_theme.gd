class_name GameTheme
extends RefCounted
## Il tema del gioco (`Session._ready`): dal 30 set 2026 passa tutto da `UiTheme` (voce 270). Prima: i suggerimenti (tooltip), che con il tema di Godot avevano il fondo
## trasparente e sopra certi sfondi non si leggevano (appunto dell'utente, 25 set 2026). Riquadro scuro con il bordo
## turchese come la Bisaccia, testo chiaro con il contorno.
## Si scrive nel tema predefinito del motore: i suggerimenti compaiono in una finestrella a sé, che non eredita il
## tema della finestra principale (assegnarlo a `root.theme` non bastava).


static func apply() -> void:
	UiTheme.apply()                          # voce 270: il tema unico (suggerimenti compresi)
