extends LinkButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	match settings.settingSound:
		true:
			set_text("Disable Click Track")
		false:
			set_text(" Enable Click Track")

func _pressed():
	settings.settingSound = !settings.settingSound
	settings.save_game()
	_ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
