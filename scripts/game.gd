extends Node2D

@onready var hand: Hand = $CanvasLayer/Hand
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
	# populate deck resource with cards and draw cards into Hand
	populate_deck()
	fill_hand()

func populate_deck() -> void:
	for s in SUITS:
		for r in NUMS:
			deck.add_card(CardResource.new(s, r))
	deck.shuffle()
	print(deck)

func fill_hand(num_cards: int = 8) -> void:
	var hand_size = hand.hand_size()
	if hand_size < MAX_HAND_SIZE:
		for i in range(MAX_HAND_SIZE - hand_size):
			var new_card_ui = card_ui_scene.instantiate()
			new_card_ui.card = deck.draw_card()
			hand.add_and_sort_child(new_card_ui)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
