extends Node

signal card_selected(card_ui, select_status)
signal cards_played(card_values)
signal cards_discarded(card_values)
signal boss_card_damaged(health_val)
signal joker_effect
signal card_pile_size_changed(pile_id: String, cards_amount: int)
