extends Area2D

func _ready():
	$AnimationPlayer.play("spell")

func _remove_self():
	self.queue_free()


func _on_bodSpell_area_entered(area):
	var body: KinematicBody2D = area.get_parent()
	body._hit(20)
