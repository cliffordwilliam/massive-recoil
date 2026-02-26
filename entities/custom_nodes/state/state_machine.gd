class_name StateMachine
extends Node

@onready var current_state: State = get_child(0)


func _ready() -> void:
	owner.ready.connect(func() -> void: current_state.enter(""))


func _physics_process(delta: float) -> void:
	current_state.process_physics(delta)


func transition_to(target_state_name: StringName) -> void:
	current_state.exit()
	var prev_name: StringName = current_state.name
	current_state = get_node(NodePath(target_state_name)) as State
	current_state.enter(prev_name)
