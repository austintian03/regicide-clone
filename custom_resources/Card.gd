class_name Card
extends Resource

enum Suit {CLUBS, DIAMONDS, HEARTS, SPADES}

@export var suit : Suit
@export var rank : int:
	set(value):
		rank = clampi(value, 1, 13)

#var texture : Texture = load_texture()
func load_texture() -> Texture2D:
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
	return load(texture_path)
