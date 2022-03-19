extends Area2D

func _ready():
	self.call_deferred("_actions_when_spawn")

func _actions_when_spawn():
	$Tween.interpolate_property($Sprite,"modulate",Color(1,1,1,0.3),Color(1,1,1,1),0.5)
	$Tween.start()
