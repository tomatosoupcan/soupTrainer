extends MenuButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dict = settings.comboDict
var characterselect = ""
var gameselect = ""
var popup

# Called when the node enters the scene tree for the first time.
func _ready():
	popup = get_popup()
	popup.clear()
	popup.connect("id_pressed", self, "_on_item_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_item_pressed(ID):
	characterselect = popup.get_item_text(ID)
	set_text("Character: "+characterselect)
	$selectCombo.popup.clear()
	$selectCombo.set_text("Combo:")
	$selectCombo.gameselect = gameselect
	$selectCombo.characterselect = characterselect
	for combo in dict[gameselect][characterselect].keys():
		$selectCombo.popup.add_item(combo)

func clear_combo():
	$selectCombo.popup.clear()
	$selectCombo.set_text("Combo:")
