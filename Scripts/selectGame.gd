extends MenuButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dict = settings.comboDict
var gameselect = ""
var popup

# Called when the node enters the scene tree for the first time.
func _ready():
	get_popup().clear()
	for game in dict.keys():
		get_popup().add_item(game)
	popup = get_popup()
	popup.connect("id_pressed", self, "_on_item_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_item_pressed(ID):
	gameselect = popup.get_item_text(ID)
	set_text("Game: "+gameselect)
	$selectCharacter.popup.clear()
	$selectCharacter.set_text("Character:")
	$selectCharacter.clear_combo()
	$selectCharacter.gameselect = gameselect
	for character in dict[gameselect].keys():
		$selectCharacter.popup.add_item(character)
