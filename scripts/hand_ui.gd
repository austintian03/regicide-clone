class_name HandUI
extends HBoxContainer

var selected_card_values: Array[int] = []
var discard_target: int = 0
var card_ui_scene = preload("res://scenes/card_ui.tscn")

func _ready() -> void:
	Events.connect("card_selected", _on_card_selected)
	
func add_and_sort_card(card_resource: CardResource) -> void:
	"Adds and sorts the hand of CardUI children as elements are added each time. Sort order based on CardResource suit and rank."
	var card = instantiate_card(card_resource)
	add_child(card)
	
	var sibling_count = get_child_count() - 1
	
	var index_to_insert = 0
	for i in range(sibling_count):
		var child = get_child(i)
		# update location based on Suit enum order
		if card.card.suit > child.card.suit: 
			index_to_insert += 1
		# once found other cards of same suit, sort by rank
		elif card.card.suit == child.card.suit:
			if card.card.rank > child.card.rank:
				index_to_insert += 1
			else:
				break
		# break once exiting the correct suit subgroup
		else:
			break
	move_child(card, index_to_insert)

func instantiate_card(card_resource: CardResource) -> CardUI:
	var card_child = card_ui_scene.instantiate() as CardUI
	card_child.card = card_resource
	card_child.add_to_group("Hand")
	return card_child

func hand_size() -> int:
	return get_child_count()

func _to_string() -> String:
	var _card_ui_children = get_children()
	var _string_array: PackedStringArray
	for card in _card_ui_children:
		_string_array.append(str(card.card))
	return ", ".join(_string_array)

# called when card_selected signal is emitted by CardUI child
func _on_card_selected(card_child: CardUI, select_status: String) -> void:
	if select_status == "select":
		card_child.add_to_group("Selected Cards")
		selected_card_values.append(card_child.card.card_value)
	elif select_status == "unselect":
		card_child.remove_from_group("Selected Cards")
		selected_card_values.erase(card_child.card.card_value)
	
	# use SceneTree to call set_selectable() on all cards in Hand based on the ranks of cards in Selected Cards group
	get_tree().call_group("Hand", "set_selectable", selected_card_values, discard_target)

func _on_play_button_pressed() -> void:
	if selected_card_values.size() > 0:
		print("Playing cards!")
		Events.emit_signal("cards_played", release_selected_cards())

func _on_discard_button_pressed() -> void:
	if selected_card_values.size() > 0:
		print("Discarding cards!")
		discard_target = 0
		Events.emit_signal("cards_discarded", release_selected_cards())

func release_selected_cards() -> Array[CardResource]:
	# release selected cards
	var selected_cards = get_tree().get_nodes_in_group("Selected Cards")
	var released_cards: Array[CardResource] = []
	for card in selected_cards:
		released_cards.append(card.release())
		card.free()
	
	# reset selectable cards
	selected_card_values.clear()
	get_tree().call_group("Hand", "toggle_selectable", true)
	
	return released_cards
