extends Node

signal died

export (int) var max_health = 20 setget _set_max_health
onready var current_health = max_health setget _set_current_health


func _set_max_health(new_max):
	max_health = max(1,new_max)


func _set_current_health(new_current):
	current_health = new_current
	current_health = clamp(current_health,0,max_health)
	
	if current_health == 0:
		emit_signal("died")
