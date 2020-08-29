extends Node

var settingSound = true
var settingFile = "user://Combos/BaseVegetaLoops.txt"
var buttonBinds = [
	["UP",["NULL",0,0]],
	["DOWN",["NULL",0,0]],
	["LEFT",["NULL",0,0]],
	["RIGHT",["NULL",0,0]],
	["L",["NULL",0,0]],
	["LK",["NULL",0,0]],
	["LP",["NULL",0,0]],
	["M",["NULL",0,0]],
	["MK",["NULL",0,0]],
	["MP",["NULL",0,0]],
	["H",["NULL",0,0]],
	["HK",["NULL",0,0]],
	["HP",["NULL",0,0]],
	["S",["NULL",0,0]],
	["1",["NULL",0,0]],
	["2",["NULL",0,0]],
	["3",["NULL",0,0]],
	["4",["NULL",0,0]],
	["5",["NULL",0,0]],
	["RESET",["NULL",0,0]]]
var comboDict = {}

func _ready():
	load_game()
	#list files in directory
	load_files()

func save():
	var save_dict = {
		"settingSound" : settingSound,
		"buttonBinds" : buttonBinds
	}
	return save_dict

func save_game():
	var save_game = File.new()
	save_game.open("user://settings.save", File.WRITE)
	save_game.store_line(to_json(save()))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://settings.save"):
		return
	
	save_game.open("user://settings.save", File.READ)
	var text = save_game.get_as_text()
	var save_dict = parse_json(text)
	settingSound = save_dict["settingSound"]
	buttonBinds = save_dict["buttonBinds"]

func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()

	var obj = Reference.new()
	obj.set_script(script)

	return obj.eval() # Supposing input is "23 + 2", returns 25

func load_files():
	var files = []
	var dir = Directory.new()
	dir.open("user://Combos/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append("user://Combos/"+file)
	dir.list_dir_end()
	for file2 in files:
		var f = File.new()
		f.open(file2, File.READ) 
		var options = f.get_as_text().split(";")
		#load options data into memory
		var gamename = ""
		var charactername = ""
		var comboname = ""
		for option in options:
			var opt = option.split("=")[0].to_lower().strip_edges()
			match opt:
				"game":
					gamename = option.split("=")[1]
				"charactername":
					charactername = option.split("=")[1]
				"comboname":
					comboname = option.split("=")[1]
		if comboDict.has(gamename):
			if comboDict[gamename].has(charactername):
				comboDict[gamename][charactername][comboname] = file2
			else:
				comboDict[gamename][charactername] = {}
				comboDict[gamename][charactername][comboname] = file2
		else:
			comboDict[gamename] = {}
			comboDict[gamename][charactername] = {}
			comboDict[gamename][charactername][comboname] = file2	
#	print(comboDict)
