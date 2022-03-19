extends KinematicBody2D

var fall_speed = 100
var floor_speed = 250
var dir_x = 1;
### Movement
var velocity =  Vector2(0,0)
var can_move = false
var in_air = true


func _physics_process(_delta) -> void:
	_movement()
	if $RayCast2D.is_colliding():
		self.queue_free()
	if is_on_floor() and in_air:
		in_air = false
	
	var _r = move_and_slide(velocity,Vector2.UP)


func _change_raycast_dir(n_d):
	$RayCast2D.cast_to.x = 34 * n_d

func _movement() -> void:
	if in_air:
		velocity.y = fall_speed 
	else:
		velocity.y = 0
		velocity.x  = floor_speed * dir_x



func _on_hitbox_body_entered(body: KinematicBody2D) -> void:
	body._hit(100)
