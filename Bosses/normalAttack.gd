extends Area2D

var color_1 = Color(120,120,120)
var color_2 = Color(120,0,0)
var current_color = 1
var time_to_hit = 0.75

func _ready():
	_change_between_colors()
	yield(get_tree().create_timer(time_to_hit),"timeout")
	$changeColor.stop()
	yield(get_tree().create_timer(0.2),"timeout")
	self.visible = false
	yield(get_tree().create_timer(0.5),"timeout")
	self.visible = true
	$CollisionShape2D.set_deferred("disabled",false)
	yield(get_tree().create_timer(0.3),"timeout")
	self.queue_free()

func _change_between_colors():
	$changeColor.wait_time = 0.15
	$changeColor.start()


func _on_changeColor_timeout():
	if current_color == 1:
		$Sprite.modulate = color_2
		current_color = 2
	else:
		$Sprite.modulate = color_1
		current_color = 1




func _on_normalAttack_area_entered(area) -> void:
	area.get_parent()._hit(100)
