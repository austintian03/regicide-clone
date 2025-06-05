extends Node2D

@onready var hand: HandUI = $CanvasLayer/HandUI
@onready var play_button: Button = $CanvasLayer/PlayButton
@onready var discard_button: Button = $CanvasLayer/DiscardButton

@onready var boss_card: BossCard = $BossUI/BossCard
@onready var health_text: Label = $BossUI/HealthLabel/HealthText
@onready var attack_text: Label = $BossUI/AttackLabel/AttackText

@onready var joker_button: TextureButton = $CanvasLayer/JokerButton
@onready var joker_button_2: TextureButton = $CanvasLayer/JokerButton2

# relevant card piles
var deck := CardPile.new("Deck")
var enemies := CardPile.new("Enemies")
var discard := CardPile.new("Discard")
var play_area := CardPile.new("Play Area")

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
	Events.connect("cards_discarded", _on_cards_discarded)
	Events.connect("joker_effect", _on_joker_effect)
	
	# populate player deck with cards and draw starting hand
	populate(deck, NUMS)
	fill_hand()
	print("Starting hand: ", hand)
	
	# populate enemy pile with the royals
	populate_enemies()
	draw_new_royal()

# connected event signals which trigger game effects
# these signals progress the game state in the order they appear in
func _on_cards_played(played_cards: Array[CardResource]) -> void:
	print("Resolving player turn")
	resolve_player_turn(played_cards)
	
func _on_boss_card_damaged(boss_health: int) -> void:
	health_text.text = str(max(boss_health, 0))
	print("Resolving boss turn")
	resolve_boss_turn(boss_health)
	
func _on_cards_discarded(discarded_cards: Array[CardResource]) -> void:
	discard.add_cards(discarded_cards)
	swap_buttons()
	
func _on_joker_effect() -> void:
	discard.add_cards(hand.discard_all())
	fill_hand()
	
# game effect functions
# these process game logic/rules using the values passed alongside the emitted game event signals
func resolve_player_turn(played_cards: Array[CardResource]) -> void:
	# resolve card effects, deal damage to boss card
	process_play_effects(played_cards)
	print("Attacking boss for ", player_damage)
	boss_card.take_damage(player_damage)

func resolve_boss_turn(boss_health: int) -> void:
	# process boss death or attack player
	if boss_health <= 0:
		process_boss_death(boss_health)
	else:
		# calc damage player is to take
		var post_mitigation_dmg = max(boss_card.do_damage() - player_defense, 0)
		print("Boss card attacking for ", post_mitigation_dmg)
		# only go to discard phase if player is taking damage
		if post_mitigation_dmg > 0:
			swap_buttons()
			hand.discard_target = post_mitigation_dmg

func process_boss_death(boss_health: int) -> void:
	# reset player defense
	player_defense = 0
	
	# move cards from play area to discard pile
	discard.add_cards(play_area.draw_cards(play_area.get_size()))
	
	# release card resource to the correct pile depending on perfect lethal or not
	if boss_health == 0:
		print("Perfect lethal!")
		deck.add_card_on_top(boss_card.on_death())
	elif boss_health < 0:
		print("Royalty vanquished.")
		discard.add_card(boss_card.on_death())
	
	# draw new boss card or win game
	if !enemies.is_empty():
		draw_new_royal()
	else:
		boss_card.queue_free()
		print("You win!")

func process_play_effects(played_cards: Array[CardResource]) -> void:
	# set player_damage to sum of played cards
	var card_sum = played_cards.reduce(func(accum: int, card: CardResource): return accum + card.card_value, 0)
	player_damage = card_sum
	
	# resolve suit effects of played cards (boss suit negates matching suit effect)
	var card_suits = played_cards.map(func(card: CardResource): return SUITS[card.suit])
	for s in SUITS:
		if s in card_suits and s != SUITS[boss_card.card.suit]:
			resolve_suit_effect(s, card_sum)
	
	play_area.add_cards(played_cards)

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
			attack_text.text = str(max(boss_card.do_damage() - player_defense, 0))

# utility functions
func fill_hand(num_cards: int = 8) -> void:
	var max_cards_can_draw = MAX_HAND_SIZE - hand.hand_size()
	var cards_to_draw = min(num_cards, max_cards_can_draw, deck.get_size())
	for i in range(cards_to_draw):
		hand.add_and_sort_card(deck.draw_card())

func swap_buttons() -> void:
	var temp_disabled = play_button.disabled
	var temp_visible = play_button.visible
	play_button.disabled = discard_button.disabled
	play_button.visible = discard_button.visible
	discard_button.disabled = temp_disabled
	discard_button.visible = temp_visible

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

func draw_new_royal() -> void:
	boss_card.set_card(enemies.draw_card())
	health_text.text = str(boss_card.health)
	attack_text.text = str(boss_card.do_damage())
