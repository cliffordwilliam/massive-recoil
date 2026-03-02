# During gameplay where the player moves around, Room must be the current scene
class_name Room
extends Node

# All Room must have a page router that shows inventory page or other pages on top of gameplay
@onready var page_router: PageRouter = $PageRouter
