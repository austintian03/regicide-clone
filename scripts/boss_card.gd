class_name BossCard
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var card: CardResource
var health: int
var attack: int

func set_card(p_card: CardResource) -> void:
	card = p_card
	sprite.texture = card.texture
	match card.rank:
		11:
			health = 20
			attack = 10
		12:
			health = 30
			attack = 15
		13:
			health = 40
			attack = 20

func take_damage(dmg: int) -> void:
	health -= dmg
	Events.emit_signal("boss_card_damaged", health)

func do_damage() -> int:
	return attack

func on_death() -> CardResource:
	return self.card
