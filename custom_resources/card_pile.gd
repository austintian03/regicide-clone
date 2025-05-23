class_name CardPile
extends Resource

signal card_pile_size_changed(cards_amount: int)

var cards : Array[CardResource] = []
var id : String

func _init(p_id: String) -> void:
	id = p_id
	
func empty() -> bool:
	return cards.is_empty()

func draw_card() -> CardResource:
	var card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return card

func draw_cards(num_cards: int) -> Array[CardResource]:
	var drawn_cards: Array[CardResource] = []
	for i in range(num_cards):
		drawn_cards.append(draw_card())
	return drawn_cards
	
func add_card(card: CardResource) -> void:
	cards.append(card)
	card_pile_size_changed.emit(cards.size())

func add_cards(added_cards: Array[CardResource]) -> void:
	cards.append_array(added_cards)
	
#func add_card_sorted(card: CardResource) -> void:
	#var cards_size = cards.size()
	#if cards_size == 0:
		#add_card(card)
	#else:
		#var index_to_insert = 0
		#for i in range(cards_size):
			#if card.suit > cards[i].suit:
				#index_to_insert += 1
			#elif card.suit == cards[i].suit:
				#if card.rank > cards[i].rank:
					#index_to_insert += 1
				#else:
					#break
			#else:
				#break
		#cards.insert(index_to_insert, card)
		#card_pile_size_changed.emit(cards.size())
	
func shuffle() -> void:
	cards.shuffle()

func clear() -> void:
	cards.clear()

func get_size() -> int:
	return cards.size()
	
func _to_string() -> String:
	var _pile_name = id + "\n" 
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s of %s" % [i+1, cards[i].rank, cards[i].Suit.keys()[cards[i].suit]])
	return  _pile_name + "\n".join(_card_strings)
