extends Node

onready var gui: TextureRect = $InventoryGUI
onready var toggleAnimation = $InventoryGUI/Toggle

func _ready():
	gui.visible = false
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		if gui.visible:
			_closeGui()
		else:
			_openGui()

func _openGui():
	$InventoryGUI/ToggleOn.play()
	gui.visible = true
	toggleAnimation.play("open")
	
func _closeGui():
	$InventoryGUI/ToggleOff.play()
	toggleAnimation.play("close")
	yield(toggleAnimation, "animation_finished")
	gui.visible = false
	
