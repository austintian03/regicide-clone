class_name CardResource
extends Resource

enum Suit {CLUBS, DIAMONDS, HEARTS, SPADES}

var suit : Suit
var rank : int:
	set(value):
		rank = clampi(value, 1, 13)
var texture : Texture2D

func _init(p_suit = "spades", p_rank = 13) -> void:
	_set_suit(p_suit)
	rank = p_rank
	_load_texture()

func _set_suit(value: String) -> void:
	match value.to_lower():
			"clubs":
				suit = Suit.CLUBS
			"diamonds":
				suit = Suit.DIAMONDS
			"hearts":
				suit = Suit.HEARTS
			"spades":
				suit = Suit.SPADES

#var texture : Texture = load_texture()
func _load_texture() -> void:
	var suit_str = Suit.keys()[suit].to_lower()
	var rank_str : String
	match rank:
		1:
			rank_str = "A"
		10:
			rank_str = "10"
		11:
			rank_str = "J"
		12:
			rank_str = "Q"
		13:
			rank_str = "K"
		_:
			rank_str = "0" + str(rank)
	
	var path_format_string = "res://assets/cards/card_%s_%s.png"
	var texture_path = path_format_string % [suit_str, rank_str]
	texture = load(texture_path)
