extends MenuButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dict = settings.comboDict
var characterselect = ""
var gameselect = ""
var comboselect = ""
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
	comboselect = popup.get_item_text(ID)
	set_text("Combo: "+comboselect)
	settings.settingFile = dict[gameselect][characterselect][comboselect]
