class_name CardUI
extends Control

enum State {BASE, HOVERED, CLICKED, UNSELECTABLE}
var current_state : State
@onready var state_label: Label = $State
@onready var texture_rect: TextureRect = $TextureRect
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@export var card : CardResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enter_state(State.BASE)
	if card:
		texture_rect.texture = card.texture

# state transition conditions
func _process(_delta: float) -> void:
	var point = get_local_mouse_position() 
	var mouse_over = Rect2(Vector2.ZERO, size).has_point(point)
	
	if mouse_over and current_state == State.BASE:
		switch_state(State.HOVERED)
	elif mouse_over == false and current_state == State.HOVERED:
		switch_state(State.BASE)
	
	if Input.is_action_pressed("right_mouse") and (current_state == State.CLICKED or current_state == State.UNSELECTABLE):
		switch_state(State.BASE)
		
func _gui_input(event: InputEvent) -> void:
	var point = get_local_mouse_position()
	var mouse_over = Rect2(Vector2.ZERO, size).has_point(point)
	
	if mouse_over and event.is_action_pressed("left_mouse") and current_state != State.UNSELECTABLE:
		if current_state != State.CLICKED:
			switch_state(State.CLICKED)
		else:
			switch_state(State.BASE)

# state handling code
func switch_state(state: State) -> void:
	if current_state != state:
		exit_state(current_state)
		enter_state(state)

func enter_state(state: State) -> void:
	current_state = state
	match current_state:
		State.BASE:
			state_label.text = "Base"
		State.CLICKED:
			Events.emit_signal("card_selected", self, "select")
			state_label.text = "Clicked"
			offset_bottom -= 30
		State.HOVERED:
			state_label.text = "Hovered"
			offset_bottom -= 15
		State.UNSELECTABLE:
			state_label.text = "Unselectable"
	#print("Entered " + state_label.text)

func exit_state(state: State) -> void:
	#print("Exiting " + state_label.text)
	match state:
		State.CLICKED:
			Events.emit_signal("card_selected", self, "unselect")
			offset_bottom += 30
		State.HOVERED:
			offset_bottom += 15

# functions used to check if cards can be selected
# to be called with the help of the manager script (HandUI),
# because elsewise a singular Card doesn't know when a neighbor Card(s) is selected
func set_selectable(selected_ranks: Array[int], discard_target: int) -> void:
	if current_state != State.CLICKED:
		var selectable = check_selectable(selected_ranks, discard_target)
		toggle_selectable(selectable)

func check_selectable(selected_ranks: Array[int], discard_target: int) -> bool:
	var count = selected_ranks.size()
	var sum = selected_ranks.reduce(func(accum, num): return accum + num, 0)
	
	# check if there's a discard target
	if discard_target > 0:
		return sum < discard_target
	
	# if nothing or an Ace is the only card chosen, everything is selectable
	if count == 0 or sum == 1:
		return true
	# if only 1 card has been chosen, then Aces are still selectable
	if count == 1 and card.rank == 1:
		return true
	# if 2 cards have been chosen and one of them is already an Ace, nothing is selectable
	if count == 2 and selected_ranks.has(1):
		return false
	# elsewise if Aces haven't been selected
	if card.rank >= 6:
		return false
	elif !selected_ranks.has(card.rank) or sum >= 10:
		return false
	return true

func toggle_selectable(selectable: bool) -> void:
	if not selectable:
		switch_state(State.UNSELECTABLE)
	else:
		switch_state(State.BASE)

func release() -> CardResource :
	print("Releasing " + str(card))
	return card
