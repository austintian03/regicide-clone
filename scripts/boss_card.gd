class_name BossCard
extends Control

@onready var card_sprite: TextureRect = $CardSprite

var card: CardResource
var health: int

func set_card(p_card: CardResource) -> void:
	card = p_card
	card_sprite.texture = card.texture
	match card.rank:
		11:
			health = 20
		12:
			health = 30
		13:
			health = 40

func take_damage(dmg: int) -> void:
	health -= dmg
	Events.emit_signal("boss_card_damaged", health)

func do_damage() -> int:
	return card.card_value

func on_death() -> CardResource:
	return self.card
