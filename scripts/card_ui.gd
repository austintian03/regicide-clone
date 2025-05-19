class_name CardUI
extends Control

enum State {BASE, HOVERED, CLICKED}
var current_state : State

@onready var color: ColorRect = $Color
@onready var state_label: Label = $State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enter_state(State.BASE)

# state transition conditions
func _process(_delta: float) -> void:
	if Input.is_action_pressed("right_mouse") and current_state == State.CLICKED:
		switch_state(State.BASE)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		if current_state != State.CLICKED:
			switch_state(State.CLICKED)
		else:
			switch_state(State.BASE)

func _on_mouse_entered() -> void:
	if current_state == State.BASE:
		switch_state(State.HOVERED)

func _on_mouse_exited() -> void:
	if current_state == State.HOVERED:
		switch_state(State.BASE)


# state handling code
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
		State.HOVERED:
			state_label.text = "Hovered"
			color.color = Color.WEB_PURPLE
	print("Entered " + state_label.text)

func exit_state(_state: State) -> void:
	print("Exiting " + state_label.text)
