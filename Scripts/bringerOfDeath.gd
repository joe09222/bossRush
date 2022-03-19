extends KinematicBody2D

var current_animation

# TARGETING
var target = null
var intial_pos = Vector2.ZERO

# Movement
var max_speed = 50
var dir_between = Vector2.ZERO
var velocity = Vector2.ZERO
var can_move = false
var get_away_dir_x = 1
var is_collide = false

### Nomal attack
var is_attack_1 = false
var time_before_attack = 0.5
var time_between_attacks = 2
var attacks_number = 50
var attacks_remaning = 50

### Spell Attack
var spell = preload("res://Scenes/Enemies/bodSpell.tscn")
var is_spell_attack = false
var spells_number = 2
var spells_remaning = 2

### health 
onready var health = $Health


func _ready():
	health.connect("died",self,"_dead")
	var _d = Global.connect("player_died",self,"_disable_player")

func _physics_process(_delta):
	current_animation = $AnimationTree.get("parameters/playback").get_current_node()
	is_collide = false
	if can_move:
		_movement()
		_flip_sprite()
	_movement_animations()
	_gravity()
	
	if $RayCast2D.is_colliding():
		get_away_dir_x = 1
		is_collide = true
	if $RayCast2D2.is_colliding():
		get_away_dir_x = -1
		is_collide = true
	
	if target != null:
		dir_between = _get_dir_between()
	
	var _r = move_and_slide(velocity,Vector2.UP)
	



### MOVEMENT
func _movement():
	velocity.x = max_speed * dir_between.x

func _get_dir_between():
	return (target.get_global_position() - self.get_global_position()).normalized()

func _flip_sprite():
	if dir_between.x > 0:
		$Sprite.flip_h = true
		$Sprite.position.x = 33.979
		$attack1Hitbox/CollisionShape2D.position.x = 51.856
	else:
		$Sprite.flip_h = false
		$Sprite.position.x = -37.755
		$attack1Hitbox/CollisionShape2D.position.x = -51.856
		

func _movement_animations():
	var is_idle = false
	var is_run = false
	if velocity.x == 0:
		is_idle = true
	elif velocity.x != 0:
		is_run = true
	$AnimationTree.set("parameters/conditions/is_idle",is_idle)
	$AnimationTree.set("parameters/conditions/is_run",is_run)

func _get_current_dir():
	if $Sprite.flip_h == false:
		return -1
	else:
		return 1


### GRAVITY 
func _gravity():
	velocity.y += 30
	velocity.y = clamp(velocity.y,0,600)



### ATTACKS

func _normal_attack():
	attacks_remaning -= 1
	velocity.x = 0
	is_attack_1 = true
	can_move = false
	$Sprite.modulate = Color.red
	if self.get_global_position().distance_to(target.get_global_position()) < 65:
		if is_collide:
			_big_dash(500 * get_away_dir_x * -1)
		else:
			_small_dash(250)
	else:
		_small_dash(-100)
	yield(get_tree().create_timer(time_before_attack),"timeout")
	$AnimationTree.set("parameters/conditions/is_attack_1",is_attack_1)
	$Sprite.modulate = Color.white

func _set_attack_1(cond:bool):
	is_attack_1 = cond
	$AnimationTree.set("parameters/conditions/is_attack_1",is_attack_1)


func _big_dash(n_force):
	velocity.x = n_force

func _small_dash(force):
	if dir_between.x > 0:
		velocity.x = -force
	else:
		velocity.x = force

	yield(get_tree().create_timer(0.3),"timeout")
	velocity.x = 0



func _spell_attack():
	spells_remaning -= 1
	can_move = false
	velocity.x = 0
	is_spell_attack = true
	$Sprite.modulate = Color.black
	_small_dash(200)
	yield(get_tree().create_timer(0.4),"timeout")
	$AnimationTree.set("parameters/conditions/is_spell_attack",is_spell_attack)
	$Sprite.modulate = Color.white
	
	
func _set_spell_attack(cond:bool):
	is_spell_attack = cond
	$AnimationTree.set("parameters/conditions/is_spell_attack",is_spell_attack)

func _spawn_wave_spell(no_of_spells:int,added_pos:Vector2,timer:float):
	yield(get_tree().create_timer(timer),"timeout")
	if target != null:
		var intial_poss = target.get_global_position()  + added_pos
		if intial_poss > self.get_global_position():
			intial_poss += Vector2(40,0)
		else:
			intial_poss += Vector2(-40,0)
		
		intial_poss.y = -23
		
		var x_inc = 0
		for spll in no_of_spells:
			if x_inc != 0:
				_spawn_spell(intial_poss,Vector2(x_inc,-45))
				_spawn_spell(intial_poss,Vector2(-x_inc,-45))
			else:
				_spawn_spell(intial_poss,Vector2(x_inc,-45))
			x_inc += 60


func _spawn_spell(intial_p,given_pos):
	var s = spell.instance()
	get_parent().add_child(s)
	s.position = intial_p + given_pos


func _reses_spells():
	if spells_remaning == 0:
		yield(get_tree().create_timer(18),"timeout")
		spells_remaning = spells_number


func _disable_attack_area(new_time:float = 0):
	$dangerArea/CollisionShape2D.set_deferred("disabled",true)
	if new_time == 0:
		yield(get_tree().create_timer(time_between_attacks),"timeout")
	else:
		yield(get_tree().create_timer(new_time),"timeout")
	$dangerArea/CollisionShape2D.set_deferred("disabled",false)
	can_move = true


### AREAS


func _on_detectionArea_body_entered(body):
	target = body
	can_move = true
	$detectionArea/CollisionShape2D.set_deferred("disabled",true)


func _on_dangerArea_body_entered(_body):
	if health.current_health > 100 and attacks_remaning > 0:
		_normal_attack()
	elif health.current_health <= 100 and spells_remaning > 0:
		_spell_attack();
	elif attacks_remaning > 0:
		_normal_attack()
	else:
		can_move = false
		velocity.x = 0
		$Sprite.modulate = Color.palevioletred






### DAMGE
func _hit(damge):
	health.current_health -= damge
	self.modulate = Color(120,120,120)
	yield(get_tree().create_timer(0.3),"timeout")
	self.modulate = Color(1,1,1)


func _knock_back(dir_x:int, force:int):
	velocity.x = dir_x * force
	yield(get_tree().create_timer(0.3),"timeout")
	velocity.x = 0

func _dead():
	self.queue_free()


func _disable_player():
	target = null
	set_physics_process(false)


func _on_attack1Hitbox_area_entered(area):
	var body: KinematicBody2D = area.get_parent()
	body._hit(20)
	body._knock_back(_get_current_dir(),200)
