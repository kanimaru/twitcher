static func flash(object: Control, color: Color, duration: float = .25) -> void:
	var tween = object.create_tween()
	tween.tween_property(object, ^"modulate", color, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(object, ^"modulate", Color.WHITE, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
	await tween.finished


static func loading(object: Control) -> void:
	var tween: Tween = object.create_tween()
	tween.tween_property(object, ^"modulate", Color.YELLOW, 0.2) \
		.set_trans(Tween.TRANS_LINEAR) \
		.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
