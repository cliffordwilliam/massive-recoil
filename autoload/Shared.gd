extends Node


onready var tree: SceneTree = get_tree()

var camera

const SLOT_SIZE = 20

func _init():
	_initItemList()

const item_db_path = "res://item/items.tres"
var item_db : Dictionary

func _initItemList():
	var file = File.new()
	file.open(item_db_path, File.READ)
	var content = file.get_as_text()
	var json = JSON.parse(content)
	item_db = json.result

var inventory_items = []

signal refresh_gui
