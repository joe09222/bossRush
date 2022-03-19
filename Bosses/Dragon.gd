extends StaticBody2D

var target = null;

var current_phase = 2
var defence = 2

var bossBar:ProgressBar 
### Normal Attack

var normal_attack = preload("res://Bosses/normalAttack.tscn")


### Fall attack
var falling_platform = preload("res://Bosses/DragonPlatform.tscn")
var fall_platform_speed = 50
var floor_platform_speed = 150
var waves_number = 0;
var is_advanced_fall_actions = true
var fall_left = 1

### Ground explosion
var explosion = preload("res://Bosses/Explosion.tscn")
var explosion_time = 1.5
var prevIndex = 100;
var explosion_waves = 0;
var time_betwen_exp_wave = 3
var exp_left = 1
var in_exp_state = false

### EYE ATTACK
var eye = preload("res://Bosses/Eye.tscn")
var eye_dir_x = -1
var eye_left = 1
onready var health = $Health



var bod = preload("res://Scenes/Enemies/bringerOfDeath.tscn");



func _ready():
	randomize()
	health.connect("died",self,"_die")
	bossBar = get_parent().get_child(0).get_child(0)
	bossBar.max_value = health.max_health
	bossBar.value = health.current_health

func _physics_process(delta):
	if in_exp_state:
		$Sprite.modulate = Color(120,60,0)

### NORMAL ATTACK
func _single_attack_pattern(numr):
	if numr == 0:
		_spawn_normal_attack(Vector2(0,35))
	else:
		_spawn_normal_attack(Vector2(0,5))

func _double_attack_pattern(numr):
	if numr == 1:
		_spawn_normal_attack(Vector2(0,5))
		yield(get_tree().create_timer(1.5),"timeout")
		_spawn_normal_attack(Vector2(0,35))
	else:
		_spawn_normal_attack(Vector2(0,35))
		yield(get_tree().create_timer(1.5),"timeout")
		_spawn_normal_attack(Vector2(0,5))

func _spawn_normal_attack(increment):
	var n = normal_attack.instance()
	var my_pos = get_global_position() + Vector2(-240,0)
	n.position = my_pos + increment
	get_parent().call_deferred("add_child",n)


### FALL ATTACK
func _spawn_platform_wave(no_of_waves:int,timer_between_waves:float) -> void:
	Global.emit_signal("darknees",true)
	waves_number = no_of_waves
	$spawnSingleWave.wait_time = timer_between_waves
	$spawnSingleWave.one_shot = false
	$spawnSingleWave.start()



func _on_spawnSingleWave_timeout():
	if waves_number > 0:
		_spawn_platform(1)
		_spawn_platform(-1)
		waves_number -= 1
	else:
		$spawnSingleWave.stop()
		yield(get_tree().create_timer(2),"timeout")
		Global.emit_signal("darknees",false)
		


func _spawn_platform(platform_dir:int) -> void:
	var p = falling_platform.instance()
	var my_pos = self.get_global_position() + Vector2(-120,0)
	p.dir_x = platform_dir * -1
	p._change_raycast_dir(platform_dir * -1)
	if is_advanced_fall_actions:
		p.floor_speed = rand_range(200,300)
		p.fall_speed = rand_range(100,120)
	if platform_dir == 1:
		p.position = my_pos + Vector2(0,-200)
	else:
		p.position = my_pos + Vector2(-340,-200)
		
	get_parent().call_deferred("add_child",p)


### Ground explosion

func _spawn_waves_exp(exp_waves:int):
	in_exp_state = true
	$Sprite.modulate = Color(120,60,0)
	yield(get_tree().create_timer(2.5),"timeout")
	_spawn_explosion_wave()
	explosion_waves = exp_waves - 1
	$spawnExplosionWave.wait_time = time_betwen_exp_wave
	$spawnExplosionWave.one_shot = false
	$spawnExplosionWave.start()


func _on_spawnExplosionWave_timeout():
	if explosion_waves > 0:
		_spawn_explosion_wave()
		explosion_waves -= 1
	else:
		$spawnExplosionWave.stop()
	if explosion_waves == 0:
		in_exp_state = false
		$Sprite.modulate = Color(1,1,1)


func _spawn_explosion_wave():
	var x_increment = 0
	_spawn_gorund_explosion(Vector2(0,0))
	_get_unique_number(0,5)
	for index in 5:
		x_increment += 68
		if index != prevIndex:
			_spawn_gorund_explosion(Vector2(-x_increment,0))

	
func _spawn_gorund_explosion(added_pos:Vector2):
	var e = explosion.instance()
	var my_pos = self.get_global_position() + Vector2(-125,36)
	e.position = my_pos + added_pos
	e.explosion_time = explosion_time
	get_parent().call_deferred("add_child",e)



func _get_unique_number(start:int,finish:int):
	var new_index = floor(rand_range(start,finish))
	if new_index == prevIndex:
		_get_unique_number(start,finish)
	else:
		prevIndex = new_index
		return

### Change dir Attacks
func _eye_attack():
	_spawn_eye()
	yield(get_tree().create_timer(1),"timeout")
	$EyeArea/CollisionShape2D.set_deferred("disabled",false)
	yield(get_tree().create_timer(4),"timeout")
	$Tween.interpolate_property(Global.current_eye,"position",Global.current_eye.position,get_global_position() + Vector2(-450,-200),0.5)
	$Tween.start()
	Global.player.can_eye = false
	yield(get_tree().create_timer(0.5),"timeout")
	Global.player.can_eye = true
	Global.player.eye_dir = eye_dir_x * -1
	yield(get_tree().create_timer(2),"timeout")
	Global.player.can_eye = false
	Global.emit_signal("darknees",false)
	Global.current_eye._remove_self()

func _spawn_eye():
	var e = eye.instance();
	var my_pos = self.get_global_position() + Vector2(-100,-200)
	if eye_dir_x == -1:
		e.position = my_pos
	else:
		e.position = my_pos + Vector2(-350,0)
	e.eye_dir_x = eye_dir_x
	get_parent().add_child(e)


func _on_dangerArea_body_entered(body: KinematicBody2D) -> void:
	target = body
	if health.current_health < 150 and eye_left > 0:
		eye_left -= 1
		_eye_attack()
		$getDangerArea.wait_time = 10
		$getDangerArea.start()
		$getEyeBack.wait_time = 30
		$getEyeBack.start()
	elif health.current_health < 300 and exp_left > 0:
		exp_left -= 1
		_spawn_waves_exp(3)
		$getDangerArea.wait_time = 15
		$getDangerArea.start()
		$getExplosionsBack.wait_time = 60
		$getExplosionsBack.start()
	elif health.current_health < 250 and fall_left > 0:
		fall_left -= 1
		_spawn_platform_wave(10,1)
		$getDangerArea.wait_time = 16
		$getDangerArea.start()
		$getFallBack.wait_time = 50
		$getFallBack.start()

	elif health.current_health < 200:
		var rand_n = floor(rand_range(0,2))
		_double_attack_pattern(rand_n)
		$getDangerArea.wait_time = 6.5
		$getDangerArea.start()
		
	else:
		var rand_nn = floor(rand_range(0,2))
		_single_attack_pattern(rand_nn)
		$getDangerArea.wait_time = 3
		$getDangerArea.start()
		
	#_double_attack_pattern(1)

	$dangerArea/CollisionShape2D.set_deferred("disabled",true)


func _on_getDangerArea_timeout():
	$dangerArea/CollisionShape2D.set_deferred("disabled",false)

func _on_getExplosionsBack_timeout():
	exp_left = 1

func _on_getFallBack_timeout():
	fall_left = 1


func _on_getEyeBack_timeout():
	eye_left = 1


func _on_EyeArea_body_entered(body):
	body.eye_dir = eye_dir_x
	body.can_eye = true
	$EyeArea/CollisionShape2D.set_deferred("disabled",true)



### DAMGE
func _hit(damge):
	health.current_health -= (damge - defence)
	bossBar.value = health.current_health
	if !in_exp_state:
		$Sprite.modulate = Color(120,120,120)
		yield(get_tree().create_timer(0.2),"timeout")
		$Sprite.modulate = Color(1,1,1)
	else:
		$Sprite.modulate = Color(120,120,120)
		in_exp_state = false
		yield(get_tree().create_timer(0.2),"timeout")
		in_exp_state = true
		$Sprite.modulate = Color(1,1,1)

func _knock_back(dir_x:int, force:int):
	return


func _die():
	var b = bod.instance();
	self.get_parent().add_child(b);
	b.position = self.position + Vector2(-200, 0);
	self.queue_free()

