class_name HandUI
extends HBoxContainer

var card_ui_scene = preload("res://scenes/card_ui.tscn")

#func _on_card_selected() -> void:
	
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
	var card_child = card_ui_scene.instantiate()
	card_child.card = card_resource
	return card_child

func hand_size() -> int:
	return get_child_count()
	
func _to_string() -> String:
	var _card_ui_children = get_children()
	var _string_array: PackedStringArray
	for card in _card_ui_children:
		_string_array.append(str(card.card))
	return ", ".join(_string_array)
