static func flash(object: Control, color: Color, duration: float = .25) -> void:
	var tween = object.create_tween()
	var previous_color = object.modulate
	tween.tween_property(object, ^"modulate", color, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(object, ^"modulate", previous_color, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
