class_name CardUI
extends Control

enum State {BASE, CLICKED}
var current_state : State

@onready var color: ColorRect = $Color
@onready var state_label: Label = $State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enter_state(State.BASE)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		if current_state == State.BASE:
			print("switching from base to clicked")
			switch_state(State.CLICKED)
		elif current_state == State.CLICKED:
			print("switching from clicked to base")
			switch_state(State.BASE)
	
	if event.is_action_pressed("right_mouse"):
		if current_state == State.CLICKED:
			print("switching from clicked to base")
			switch_state(State.BASE)
		

func switch_state(state: State) -> void:
	exit_state(current_state)
	enter_state(state)
	
func enter_state(state: State) -> void:
	current_state = state
	match current_state:
		State.BASE:
			state_label.text = "Base"
			color.color = Color.WEB_GREEN
		State.CLICKED:
			state_label.text = "Clicked"
			color.color = Color.ORANGE
			
			
func exit_state(_state: State) -> void:
	pass
