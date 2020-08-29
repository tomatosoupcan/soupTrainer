extends LinkButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var buttonBinding = false
var buttonBinds = settings.buttonBinds
var buttonPressed = ["",0,0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _pressed():
	var index = 0
	for button in buttonBinds:
		$bindText.set_text("Enter preffered input for "+button[0])
		buttonBinding = true
		while buttonBinding:
			yield(get_tree().create_timer(0.1),"timeout")
			pass
		buttonBinds[index][1] = buttonPressed
		yield(get_tree().create_timer(0.5),"timeout")
		index+=1
	settings.buttonBinds = buttonBinds
	$bindText.set_text("")
#	print(settings.buttonBinds)
	settings.save_game()

func _input(event):
	if buttonBinding == true && (event is InputEventKey or event is InputEventJoypadButton || event is InputEventJoypadMotion):
		if event is InputEventKey:
			buttonPressed = ["InputEventKey",event.scancode,0]
		elif event is InputEventJoypadButton:
			buttonPressed = ["InputEventJoypadButton",event.button_index,0]
		elif event is InputEventJoypadMotion:
			buttonPressed = ["InputEventJoypadMotion",event.axis, event.axis_value]
		buttonBinding = false
