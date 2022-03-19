extends Area2D




func _on_jumpBooster_body_entered(body):
	self.queue_free()
	body.jumps_left += 1
