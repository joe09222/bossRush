extends KinematicBody2D

var current_animation;

### Movement
var default_max_speed = 64
var max_speed : int = 64
var dir_x: int = 1
var velocity: Vector2 = Vector2.ZERO
var can_move: bool = true


### Gravity  
var gravity = 20;
var max_gravity = 800
var is_gravity = true

### Jumping
var jump_number = 1
var jumps_left = 1
var jump_force = 350
var can_jump = true
var can_land = false

### Crouching
var crouch_speed = 16
var is_crouching = false
var can_crouch = true

### Dashing
var dash_number = 2
var dashes_left = 2
var dash_duration = 0.29
var dash_cd = 1
var dash_force = 200
var can_dash = true

### Attacking
var can_change_dir = true
var can_attack = true
var detect_attack_2 = false
var detect_attack_3 = false
var is_attack_2 = false
var is_attack_3 = false
var attack_dir_x = 1

### Dragon
var can_eye = false
var eye_dir = 0;


### health
onready var health = $Health

func _ready():
	Global.player = self
	health.connect("died",self,"_die")
	var _y = Global.connect("darknees",self,"_light_self")

func _light_self(cond):
	$Light2D.enabled = cond

func _physics_process(_delta):
	current_animation = $AnimationTree.get("parameters/playback").get_current_node()
	if can_move:
		_movement()
	if is_crouching == false:
		_movement_animations()
	if is_gravity:
		_gravity()
	if can_jump:
		_jump()
	_jump_animations()
	if can_crouch:
		_crouch()
	if can_attack:
		_attack()
	if can_dash:
		_dash()
	if can_eye:
		_eye_effect()
	
	
	var _r = move_and_slide(velocity,Vector2.UP)

### MOVEMENT
func _movement():
	velocity.x = 0
	if Input.is_action_pressed("right"):
		_movement_actions(1,false)
	if Input.is_action_pressed("left"):
		_movement_actions(-1,true)

func _movement_actions(given_dir: int,is_flip: bool):
	dir_x = given_dir
	if is_crouching:
		velocity.x = crouch_speed * dir_x 
	else:
		velocity.x = max_speed * dir_x
	if can_change_dir:
		attack_dir_x = given_dir
		_flip_sprites(is_flip)
		_move_sword_hitbox(given_dir)

func _flip_sprites(cond):
	$idle.flip_h = cond
	$run.flip_h = cond
	$jump.flip_h = cond
	$attack.flip_h = cond
	$attack2.flip_h = cond
	$attack3.flip_h = cond
	$jumpAttack.flip_h = cond
	$crouch.flip_h = cond
	$crouchAttack.flip_h = cond
	$Dash.flip_h = cond
	$Death.flip_h = cond
	$hurt.flip_h = cond
	$spinAttack.flip_h = cond
	$fastMagic.flip_h = cond
	$sustainMagic.flip_h = cond

func _move_sword_hitbox(g_dir):
	if g_dir == 1:
		$swordHitbox1/a1.position.x = 15.136
		$swordHitbox2/a3.position.x = 14
	else:
		$swordHitbox1/a1.position.x = -15.136
		$swordHitbox2/a3.position.x = -14

func _movement_animations():
	var is_idle = false
	var is_run = false
	
	if velocity.x == 0 and is_on_floor():
		is_idle = true
	elif velocity.x != 0 and is_on_floor():
		is_run = true
	$AnimationTree.set("parameters/conditions/is_idle",is_idle)
	$AnimationTree.set("parameters/conditions/is_run",is_run)



### GRAVITY 
func _gravity():
	if is_on_floor():
		velocity.y = 30;
	elif !is_on_floor():
		velocity.y += gravity
		velocity.y = clamp(velocity.y,-2000,max_gravity)


### JUMPING
func _jump():
	if is_on_floor():
		jumps_left = jump_number
	if Input.is_action_just_pressed("space") and jumps_left > 0:
		jumps_left -= 1
		velocity.y = -jump_force
		is_gravity = true
		_enable_movement()
		_disable_attacks_if_incomplete()
		_stop_change_dir(false)
		_disable_sword_areas()
		


func _jump_animations():
	$AnimationTree.set("parameters/conditions/is_jump",!is_on_floor() and velocity.y < 0)
	$AnimationTree.set("parameters/conditions/is_fall",!is_on_floor() and velocity.y > 0)
	$AnimationTree.set("parameters/conditions/is_land",can_land and is_on_floor())

	if is_on_floor():
		can_land = false

func _set_land():
	can_land = true
	


### CROUCHING
func _crouch():
	is_crouching = false
	if Input.is_action_pressed("down") and is_on_floor():
		is_crouching = true
		

	$AnimationTree.set("parameters/conditions/is_crouch",is_crouching)

# Starts at the begning of crouch only
func _disable_remaning_movement_animations():
	$AnimationTree.set("parameters/conditions/is_idle",false)
	$AnimationTree.set("parameters/conditions/is_run",false)
	_enable_movement()
	_disable_attacks_if_incomplete()
	_stop_change_dir(false)
	_disable_sword_areas()
	


### Dashing
func _dash():
	var is_dash = false
	if Input.is_action_just_pressed("e") and can_dash and dashes_left > 0:
		_stop_hitbox_area(true)
		if dir_x == 1:
			_flip_sprites(false)
		else:
			_flip_sprites(true)
		_enable_movement()
		_disable_attacks_if_incomplete()
		_stop_change_dir(false)
		_disable_sword_areas()
		is_dash = true
		dashes_left -= 1
		_actions_when_dash(false)
		velocity.y = 5
		velocity.x = dir_x * dash_force
		$stopDash.wait_time = dash_duration
		$stopDash.start()
		if dashes_left == dash_number - 1:
			$resetDash.wait_time = dash_cd
			$resetDash.start()
	$AnimationTree.set("parameters/conditions/is_dash",is_dash)

func _actions_when_dash(cond):
	can_move = cond
	can_attack = cond
	can_dash = cond
	is_gravity = cond

func _on_stopDash_timeout():
	_actions_when_dash(true)
	_stop_hitbox_area(false)


func _on_resetDash_timeout():
	dashes_left = dash_number

func _stop_hitbox_area(cond:bool):
	$hitBox/CollisionShape2D.set_deferred("disabled",cond)
	

### Attacking 
func _attack():
	var is_jump_attack = false
	var is_attack_1 = false
	var is_crouch_attack = false
	if Input.is_action_just_pressed("q"):
		### Jump attacks
		if !is_on_floor():
			is_jump_attack = true
		### Ground attacks
		elif is_on_floor() and !is_crouching:
			if detect_attack_2:
				is_attack_2 = true
			elif detect_attack_3:
				is_attack_3 = true
			else:
				is_attack_1 = true
				_disable_attacks_if_incomplete()
		elif is_on_floor() and is_crouching:
			is_crouch_attack = true
	
	$AnimationTree.set("parameters/conditions/is_jump_attack",is_jump_attack)
	$AnimationTree.set("parameters/conditions/is_attack_1",is_attack_1)
	$AnimationTree.set("parameters/conditions/is_attack_2",is_attack_2)
	$AnimationTree.set("parameters/conditions/is_attack_3",is_attack_3)
	$AnimationTree.set("parameters/conditions/is_crouch_attack",is_crouch_attack)

func _disable_movement(new_speed:int):
	max_speed = new_speed

func _enable_movement():
	max_speed = default_max_speed

func _detect_attack_2(g_cond:bool):
	detect_attack_2 = g_cond

func _detect_attack_3(gi_cond:bool):
	detect_attack_3 = gi_cond

func _disable_attack(attack_num:int):
	if attack_num == 2:
		is_attack_2 = false
	else:
		is_attack_3 = false

func _disable_attacks_if_incomplete():
	detect_attack_2 = false
	detect_attack_3 = false

func _stop_change_dir(g_cond:bool):
	can_change_dir = !g_cond



func _disable_sword_areas():
	$swordHitbox1/a1.set_deferred("disabled",true)
	$swordHitbox1/a2.set_deferred("disabled",true)
	$swordHitbox2/a3.set_deferred("disabled",true)




func _on_swordHitbox1_area_entered(area):
	var body = area.get_parent()
	body._hit(6)
	body._knock_back(attack_dir_x,30)


func _on_swordHitbox2_area_entered(area):
	var body = area.get_parent()
	body._hit(9)
	body._knock_back(attack_dir_x,70)
	

### DAMGE
func _hit(damge):
	self.modulate = Color(120,120,120)
	health.current_health -= damge
	yield(get_tree().create_timer(0.3),"timeout")
	self.modulate = Color(1,1,1)

func _knock_back(dir_x_given:int, force:int):
	velocity.x = dir_x_given * force
	can_move = false
	yield(get_tree().create_timer(0.3),"timeout")
	velocity.x = 0
	can_move = true


func _die():
	Global.emit_signal("player_died")
	get_tree().reload_current_scene()
	self.queue_free()


### Dragon

func _eye_effect():
	if dir_x != eye_dir:
		_hit(0.1)

func _change_dir(n_d):
	eye_dir = n_d
