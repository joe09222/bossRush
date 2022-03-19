extends KinematicBody2D

var target = null


### attack_1
var spell_1 = preload("res://Scenes/Enemies/spell_1.tscn")

### ATTACK 1

func _attack_1():
	_spawn_spell_wave(5)

func _spawn_spell(new_pos):
	var s = spell_1.instance()
	s.position = new_pos
	get_parent().get_parent().call_deferred("add_child",s)

func _spawn_spell_wave(no_of_spells):
	var my_pos = self.get_global_position() + Vector2(-100,0)
	var incr = Vector2(0,0)
	for spell in no_of_spells:
		_spawn_spell(my_pos + incr)
		incr.y -= 30


func _on_DangerArea_body_entered(body):
	target = body
	_attack_1()
