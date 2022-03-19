extends KinematicBody2D


### TARGETING
var target = null
var intial_pos;

### Movement
var max_speed = 70
var dir_between = Vector2.ZERO
var can_move = false
var velocity = Vector2.ZERO

### Attack1
var time_to_attack = 0.5
var is_attack_1 = false
var reamning_attacks = 2
var get_normal_attack_back_timer = 2;

### Attack2 
var time_to_attack_2 = 0.5
var is_attack_2 = false
var remaning_attacks_2 = 2


func _physics_process(delta):
	if target != null:
		dir_between = _get_dir_between() 
		_flip_sprite()
	if can_move:
		_movement()
	_movement_animations()
	var _r = move_and_slide(velocity)
		

### MOVEMENT
func _movement() -> void:
	if can_move:
		velocity.x = max_speed * dir_between.x

func _get_dir_between() -> Vector2:
	return (target.get_global_position() - self.get_global_position()).normalized();

func _flip_sprite() -> void:
	if dir_between.x < 0:
		$idle.flip_h = true
		$run.flip_h = true
		$attack1.flip_h = true
		$attack2.flip_h = true
		$death.flip_h = true
	else:
		$idle.flip_h = false
		$run.flip_h = false
		$attack1.flip_h = false
		$attack2.flip_h = false
		$death.flip_h = false

func _movement_animations():
	var is_idle = false
	var is_run = false 
	if velocity.x == 0:
		is_idle = true
	elif velocity.x != 0:
		is_run = true
	$AnimationTree.set("parameters/conditions/is_idle",is_idle)
	$AnimationTree.set("parameters/conditions/is_run",is_run)
	
	

### ATTACKS

func _attack_1():
	if reamning_attacks > 0:
		reamning_attacks -= 1
		can_move = false
		velocity.x = 0
		self.modulate = Color.red
		yield(get_tree().create_timer(time_to_attack),"timeout")
		self.modulate = Color.white
		is_attack_1 = true
		$AnimationTree.set("parameters/conditions/is_attack_1",is_attack_1)
	else:
		_attack_2()
		yield(get_tree().create_timer(get_normal_attack_back_timer),"timeout")
		reamning_attacks = floor(rand_range(1,4))

func _disable_attack_1():
	is_attack_1 = false
	$AnimationTree.set("parameters/conditions/is_attack_1",is_attack_1)

func _attack_2():
	if remaning_attacks_2 > 0:
		remaning_attacks_2 -= 1
		can_move = false
		velocity.x = 0
		self.modulate = Color.red
		yield(get_tree().create_timer(time_to_attack),"timeout")
		self.modulate = Color.white
		is_attack_2 = true
		$AnimationTree.set("parameters/conditions/is_attack_2",is_attack_2)
	else:
		yield(get_tree().create_timer(get_normal_attack_back_timer),"timeout")
		remaning_attacks_2 = floor(rand_range(1,3))

func _disable_attack_2():
	is_attack_2 = false
	$AnimationTree.set("parameters/conditions/is_attack_2",is_attack_2)

func _action_to_danger_area(timer_given:float):
	$dangerArea/CollisionShape2D.set_deferred("disabled",true)
	yield(get_tree().create_timer(timer_given),"timeout")
	$dangerArea/CollisionShape2D.set_deferred("disabled",false)

func _small_dash(force:int):
	velocity.x = force * dir_between.x
	yield(get_tree().create_timer(0.3),"timeout")
	velocity.x = 0

### Collision Areas

func _on_triggerZone_body_entered(body) -> void:
	target = body;
	can_move = true
	$triggerZone/CollisionShape2D.set_deferred("disabled",true)


func _on_dangerArea_body_entered(_body):
	_attack_1()

