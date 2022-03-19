extends Sprite

var eye_dir_x = 0;
var time = 0.5

func _ready():
	Global.current_eye = self
	$Tween.interpolate_property(self,"modulate",Color(1,1,1,0),Color(1,1,1,1),time)
	$Tween.start()
	Global.emit_signal("darknees",true)

func _remove_self():
	self.queue_free()
