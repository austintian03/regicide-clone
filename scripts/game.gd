extends Node2D

@onready var hand: HandUI = $CanvasLayer/HandUI
@onready var boss_card: BossCard = $BossCard

var deck := CardPile.new("Deck")
var enemies := CardPile.new("Enemies")
var discard := CardPile.new("Discard")
var card_ui_scene = preload("res://scenes/card_ui.tscn")

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
	print(pile)

func populate_enemies() -> void:
	var temp_pile = CardPile.new("temp")
	for r in ROYALS:
		populate(temp_pile, [r])
		enemies.add_cards(temp_pile.draw_cards(temp_pile.get_size()))
		
func fill_hand(num_cards: int = 8) -> void:
	var hand_size = hand.hand_size()
	if hand_size < MAX_HAND_SIZE:
		for i in range(MAX_HAND_SIZE - hand_size):
			var new_card_ui = card_ui_scene.instantiate()
			new_card_ui.card = deck.draw_card()
			hand.add_and_sort_child(new_card_ui)
	print(hand)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
