extends KinematicBody2D

var velocity = Vector2.ZERO


func _physics_process(_delta):
	
	var _r = move_and_slide(velocity)

