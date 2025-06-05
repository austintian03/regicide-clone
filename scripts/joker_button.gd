extends TextureButton

func _on_pressed() -> void:
	self.disabled = true
	Events.emit_signal("joker_effect")
