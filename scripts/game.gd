extends Node2D

@onready var hand: HandUI = $CanvasLayer/HandUI
@onready var boss_card: BossCard = $BossCard

# relevant card piles
var deck := CardPile.new("Deck")
var enemies := CardPile.new("Enemies")
var discard := CardPile.new("Discard")

# relevant player information
var player_damage: int = 0
var player_defense: int = 0

# constants
const MAX_HAND_SIZE = 8
const SUITS = ["clubs", "hearts", "spades", "diamonds"]
const NUMS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
const ROYALS = [11, 12, 13]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect event signals that trigger game effects
	Events.connect("cards_played", _on_cards_played)
	Events.connect("boss_card_damaged", _on_boss_card_damaged)
	
	# populate player deck with cards and draw starting hand
	populate(deck, NUMS)
	fill_hand()
	print("Starting hand: ", hand)
	
	# populate enemy pile with the royals
	populate_enemies()
	boss_card.set_card(enemies.draw_card())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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

# connected signal events which trigger game effects
func _on_boss_card_damaged(boss_health: int) -> void:
	print("Resolving boss turn")
	resolve_boss_turn(boss_health)

func _on_cards_played(played_cards: Array[CardResource]) -> void:
	print("Resolving player turn")
	# resolve card effects, deal damage to boss card
	resolve_player_turn(played_cards)

# game effect functions
func resolve_player_turn(played_cards: Array[CardResource]) -> void:
	process_play_effects(played_cards)
	print("Attacking boss for ", player_damage)
	boss_card.take_damage(player_damage)

func resolve_boss_turn(boss_health: int) -> void:
	if boss_health <= 0:
		process_boss_death(boss_health)
	else:
		print("Boss card attacking!")
		var post_mitigation_dmg = max(boss_card.do_damage() - player_defense, 0)
		Events.emit_signal("boss_card_attacking", post_mitigation_dmg, player_defense)

func process_boss_death(boss_health: int) -> void:
	# release card resource to the correct pile depending on perfect lethal or not
	if boss_health == 0:
		print("Perfect lethal!")
		deck.add_card_on_top(boss_card.on_death())
	elif boss_health < 0:
		print("Royalty vanquished.")
		discard.add_card(boss_card.on_death())
	
	# draw new boss card or win game
	if enemies.get_size() > 0:
		boss_card.set_card(enemies.draw_card())
	else:
		boss_card.queue_free()
		print("You win!")

func process_play_effects(played_cards: Array[CardResource]) -> void:
	# set player_damage to sum of played cards
	var card_sum = played_cards.reduce(func(accum, card): return accum + card.rank, 0)
	player_damage = card_sum
	
	# resolve suit effects of played cards (boss suit negates matching suit effect)
	var card_suits = played_cards.map(func(card): return SUITS[card.suit])
	for s in SUITS:
		if s in card_suits and s != SUITS[boss_card.card.suit]:
			resolve_suit_effect(s, card_sum)

func resolve_suit_effect(suit: String, val: int) -> void:
	match suit:
		# double damage
		"clubs": 
			player_damage *= 2
			print("Doubled damage to ", player_damage)
		# draw cards to hand
		"diamonds":
			print("Drawing up to ", val)
			fill_hand(val)
		# restore random cards from discard to bottom of deck
		"hearts":
			print("Restoring up to ", val, " cards back to Tavern deck")
			discard.shuffle()
			deck.add_cards(discard.draw_cards(val))
		# add defense
		"spades":
			player_defense += val
			print("Defense is now ", player_defense)
