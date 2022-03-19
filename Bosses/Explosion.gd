extends Area2D

var explosion_time = 0.5

func _ready():
	yield(get_tree().create_timer(explosion_time),"timeout")
	$CollisionShape2D.set_deferred("disabled",false)
	$Sprite.modulate = Color(1,1,1,0.3)
	yield(get_tree().create_timer(0.5),"timeout")
	self.queue_free()





func _on_Explosion_body_entered(body):
	body._hit(100)
