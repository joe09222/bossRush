extends KinematicBody2D


var explosion = preload("res://Bosses/Explosion.tscn")

var positions: Node

func _spawn_thing(new_pos):
	var e = explosion.instance()
	e.position = new_pos
	get_parent().get_parent().get_parent().get_parent().call_deferred("add_child",e)

func _ready():
	positions = get_parent().get_parent().get_parent().get_parent().get_child(0)
	for index in positions.get_child_count():
		var current_pos = positions.get_child(index).position
		_spawn_thing(current_pos)
