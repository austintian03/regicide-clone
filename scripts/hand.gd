class_name HandUI
extends HBoxContainer

func add_and_sort_child(card: CardUI) -> void:
	"Adds and sorts the hand of CardUI children as elements are added each time. Sort order based on CardResource suit and rank."
	var child_count = get_child_count()
	# first child node to be added just call add_child
	if child_count == 0:
		add_child(card)
	# else, sorted insert based on suit and rank hierarchy
	else:
		var index_to_insert = 0
		for i in range(child_count):
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
		add_child(card)
		move_child(card, index_to_insert)

func hand_size() -> int:
	return get_child_count()
	
