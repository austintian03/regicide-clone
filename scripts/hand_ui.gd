class_name HandUI
extends HBoxContainer

var card_ui_scene = preload("res://scenes/card_ui.tscn")

var selected_card_ranks: Array[int] = []

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
	card_child.card_selected.connect(_on_card_selected)
	card_child.add_to_group("Hand")
	return card_child

# called when card_selected signal is emitted by CardUI child 
func _on_card_selected(card_rank: int, select_status: String) -> void:
	if select_status == "select":
		selected_card_ranks.append(card_rank)
	elif select_status == "unselect":
		selected_card_ranks.erase(card_rank)
	# use SceneTree to call set_selectable() on all cards in Hand w/ list of selected cards as argument
	get_tree().call_group("Hand", "set_selectable", selected_card_ranks)

func hand_size() -> int:
	return get_child_count()

func _to_string() -> String:
	var _card_ui_children = get_children()
	var _string_array: PackedStringArray
	for card in _card_ui_children:
		_string_array.append(str(card.card))
	return ", ".join(_string_array)
