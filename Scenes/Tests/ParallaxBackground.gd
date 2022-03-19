extends ParallaxBackground

export (Color) var color;

func _ready():
	Global.connect("darknees",self,"_change_modulate")


func _change_modulate(cond):
	if cond:
		$bg1/Sprite.modulate = color
		$bg2/Sprite.modulate = color
		$bg3/Sprite.modulate = color
	else:
		$bg1/Sprite.modulate = Color.white
		$bg2/Sprite.modulate = Color.white
		$bg3/Sprite.modulate = Color.white
