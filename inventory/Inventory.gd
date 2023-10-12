class_name Inventory extends Node

onready var gui: TextureRect = $InventoryGUI
onready var toggleAnimation = $InventoryGUI/Toggle
onready var slotGrid = $InventoryGUI/SlotGrid
var inventory_items : Array

func _ready():
	gui.visible = false
	Shared.connect("refresh_gui", self, "_refresh_gui")
	return

func _init():
	inventory_items = Shared.inventory_items
	var snowball = InventoryItemFactory.new("SNOWBALL", Vector2(0,0))._build()
	var snowball2 = InventoryItemFactory.new("SNOWBALL2", Vector2(1,0))._build()
	var snowball3 = InventoryItemFactory.new("SNOWBALL3", Vector2(3,0))._build()
	inventory_items.append(snowball)
	#inventory_items.append(snowball2)
	inventory_items.append(snowball3)
	return

func _input(event):
	if event.is_action_pressed("inventory_toggle"):
		if gui.visible:
			_closeGui()
		else:
			_openGui()

func _refresh_gui():
	_cleanup_items()
	_render_items()

func _render_items():
	for inventory_item in inventory_items:
		var slot: Slot = slotGrid._get_slot(inventory_item.pos.x, inventory_item.pos.y)
		slot.container.add_child(inventory_item._get_item())

func _cleanup_items():
	var slot_grid = self.get_child(0).get_child(0)
	for slot in slot_grid.get_children():
		if slot.container.get_child_count() == 0:
			continue
		slot.container.remove_child(slot.container.get_child(0))

func _openGui():
	$InventoryGUI/ToggleOn.play()
	gui.visible = true
	toggleAnimation.play("open")
	_render_items()
	
func _closeGui():
	$InventoryGUI/ToggleOff.play()
	toggleAnimation.play("close")
	yield(toggleAnimation, "animation_finished")
	gui.visible = false
	_cleanup_items()	
