extends Node2D

@onready var hand: HandUI = $CanvasLayer/HandUI
@onready var boss_card: BossCard = $BossCard

var deck := CardPile.new("Deck")
var enemies := CardPile.new("Enemies")
var discard := CardPile.new("Discard")

const MAX_HAND_SIZE = 8
const SUITS = ["clubs", "diamonds", "hearts", "spades"]
const NUMS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
const ROYALS = [11, 12, 13]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# populate player deck with cards and draw starting hand
	populate(deck, NUMS)
	fill_hand()
	# populate enemy pile with the royals
	populate_enemies()
	boss_card.set_card(enemies.draw_card())

func populate(pile: CardPile, ranks: Array) -> void:
	for s in SUITS:
		for r in ranks:
			pile.add_card(CardResource.new(s, r))
	pile.shuffle()
	#print(pile)

func populate_enemies() -> void:
	var temp_pile = CardPile.new("temp")
	for r in ROYALS:
		populate(temp_pile, [r])
		enemies.add_cards(temp_pile.draw_cards(temp_pile.get_size()))
		
func fill_hand(num_cards: int = 8) -> void:
	var max_cards_can_draw = MAX_HAND_SIZE - hand.hand_size()
	var cards_to_draw = min(num_cards, max_cards_can_draw)
	for i in range(cards_to_draw):
		hand.add_and_sort_card(deck.draw_card())
	print(hand)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
