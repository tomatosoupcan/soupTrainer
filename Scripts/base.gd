extends Node2D
#initialize variables
var arrowbasecount = 8 #base number of arrows to display on screen, max 12
var positions = [] #stores the positions of the arrow bases
var positionimage = [ #stores the images for each slot, to be configured in settings
	'res://Arrows/arrow_left.png',
	'res://Arrows/arrow_down.png',
	'res://Arrows/arrow_up.png',
	'res://Arrows/arrow_right.png',
	'res://Arrows/arrow_l.png',
	'res://Arrows/arrow_m.png',
	'res://Arrows/arrow_h.png',
	'res://Arrows/arrow_s.png',
	'res://Arrows/arrow_1.png',
	'res://Arrows/arrow_2.png',
	'res://Arrows/arrow_3.png',
	'res://Arrows/arrow_4.png']
var arrowins = preload("res://Scenes/arrow_base.tscn") #preload the arrow scene
var loadedarrows = [] #stores arrows currently on screen
var ignoredarrows = [] #stores arrows missed that cannot be hit again
var unsoundedarrows = []
var basearrows = [] #stores the arrow bases
var _timer = null #timer to spawn new arrows, to be replaced with file parse
var checks = [ #timing window, text, passthru, color
	[0,"Marvelous!!",1,Color(0.94, 0.94, 0.62, 1)],
	[4,"Perfect!!",1,Color(0.95, 0.89, 0.04, 1)],
	[16,"Great!",1,Color(0.37, 0.8, 0.32, 1)],
	[32,"Good",1,Color(0.32, 0.46, 0.8, 1)],
	[48,"Almost",0,Color(0.8, 0.32, 0.66, 1)],
	[80,"Boo",0,Color(0.8, 0.32, 0.32, 1)]]
var combo = 0 #current combo count
var combostring = [] #full combo string
var gamename = "" #game name from file
var comboname = "" #combo name from file
var charactername = "" #character name from file
var framerate = 60 #framerate from file
var comboinputs = [] #stores the distinct inputs in the combo
#preffered ordering of onscreen inputs
var ordered_inputs = ["LEFT","DOWN","UP","RIGHT","L","M","H","LP","LK","MP","MK","HP","HK","S","1","2","3","4","5"]
var currentframe = -10 #start frame count, a bit under 0 for reasons
var maxframe = -20 #placeholder minimum max frame
var _debugrandomarrow = false #toggle to turn on random arrows
var firsthitoffsetflag = false #rollback combo code
var file = settings.settingFile #name of the file we are reading
var settingSound = settings.settingSound #toggle for click beat

#called on startup when scene is loaded
func _ready():
	#read in combo file manually for now
	load_combo(file)
	#get the highest frame in the file
	for line in combostring:
		if line[1] > maxframe:
			maxframe = line[1]
	randomize() #randomize for testing purposes
	createbase(arrowbasecount) #loop in the base arrows
	get_tree().get_root().set_transparent_background(true); #transparent bg
	#creates a timer that runs every wait time seconds, calls randomarrow
	if _debugrandomarrow:
		_timer = Timer.new()
		add_child(_timer)
		_timer.connect("timeout", self, "randomarrow")
		_timer.set_wait_time(0.25)
		_timer.set_one_shot(false)
		_timer.start()
	get_node("reactiontext").text = "" #clear text
	get_node("combotext").text = "" #clear text
			

#called on every frame
func _process(delta):
	#check each arrow that is loaded to see if it is off screen
	#if the arrow is not offscreen, move it towards off screen
	#if the arrow is off screen, remove it
	for arrow in unsoundedarrows:
		if arrow.position[1] <= 34 && arrow.position[1] >= 30 && arrow.sounded == false:
			for arrow2 in unsoundedarrows:
				if arrow2.position[1] == arrow.position[1]:
					arrow.sounded = true
			if settingSound == true:
				$woodblock.play()
	for arrow in unsoundedarrows:
		arrow.position = arrow.position.move_toward(arrow.targetposition,delta * arrow.speed)
		if arrow.position[1] == -96:
			if !(arrow in ignoredarrows) && (arrow in loadedarrows): #check for completely missed arrows
				combo = 0
				get_node("combotext").text = ""
				get_node("reactiontext").text = checks[5][1]
				get_node("reactiontext").add_color_override("font_color", checks[5][3])
			loadedarrows.erase(arrow)
			ignoredarrows.erase(arrow)
			unsoundedarrows.erase(arrow)
			remove_child(arrow)
	#increment current frame and spawn an arrow if we're on the right frame
	if currentframe >= maxframe+int(framerate)*3.5:
		currentframe = -10
		firsthitoffsetflag = false
		combo = 0
		get_node("reactiontext").text = "" #clear text
		get_node("combotext").text = "" #clear text
	else:
		currentframe += 1
	framearrow(currentframe)

#handles input
func _input(event):
	#check if input is a key or button
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var i = 0
		if event.is_action_pressed("ui_reset"):
			reset()
		#for each arrow base, check if the associated ui_ is pressed
		for position in positions:
			i+=1
			#if pressed, invert the image and check for overlap
			if event.is_action_pressed("ui_arrow"+str(i)):
				var modify = get_node("arrow_base"+str(i)).get_node("arrow_image")
				modify.modulate = Color(0.2,0.2,0.2,1)
				checkforoverlap(position, i)
			#if released set the image back
			elif event.is_action_released("ui_arrow"+str(i)):
				var modify = get_node("arrow_base"+str(i)).get_node("arrow_image")
				modify.modulate = Color(1,1,1,1)

#generates a random arrow at the bottom of the screen, to be replaced
func randomarrow():
	var r = floor(rand_range(0, positions.size())) #random 0,number of arrow bases
	#create arrow
	var arrow = arrowins.instance();
	add_child(arrow)
	arrow.position = Vector2(positions[r], 624)
	#set a position for the arrow to head to
	arrow.targetposition = Vector2(positions[r],-96)
	arrow.get_node("arrow_image").texture = load(positionimage[r])
	arrow.apply_scale(Vector2(0.95,0.95))
	arrow.get_node("arrow_image").position = Vector2(34,32)
	arrow.get_node("arrow_image").modulate = Color(.7,.7,.7,1)
	loadedarrows.append(arrow) #put the arrow into the loaded arrow array
	return arrow

#check if an input should be spawned on a specific frame, and if so, spawn it
func framearrow(frame):
	var frameindex = 0
	var selectframe = -20
	#check if there is a valid input for the current frame
	for line in combostring:
		if line[1] == frame:
			selectframe = frameindex
		frameindex+=1
	#if there is a valid input
	if selectframe != -20:
		#for each input needed
		for input in combostring[selectframe][0]:
			#find the proper index for the right column to spawn in
			var r = comboinputs.find(input)
			#create arrow
			var arrow = arrowins.instance();
			add_child(arrow)
			arrow.position = Vector2(positions[r], 624)
			#set a position for the arrow to head to
			arrow.targetposition = Vector2(positions[r],-96)
			arrow.get_node("arrow_image").texture = load(positionimage[r])
			arrow.apply_scale(Vector2(0.95,0.95))
			arrow.get_node("arrow_image").position = Vector2(34,32)
			arrow.get_node("arrow_image").modulate = Color(.7,.7,.7,1)
			loadedarrows.append(arrow) #put the arrow into the loaded arrow array
			unsoundedarrows.append(arrow) #put the arrow in the list of arrows to play sounds

#checks for overlap near the position and column
func checkforoverlap(pos, i):
	#set the center of the arrow base i
	var center = get_node("arrow_base"+str(i)).position[1]
	#loop through loaded arrows
	for arrow in loadedarrows:
		#ignore arrows that were missed, so they can't be hit again
		if arrow in ignoredarrows:
			break
		#if arrow is in same column as arrow base
		if arrow.position[0] == pos:
			#loop through the available timing windows and return the appropriate one
			for check in checks:
				if arrow.position[1] <= center+check[0] && arrow.position[1] >= center-check[0]:
					if check[2] == 1:
						#remove the arrow if it doesn't have passthru
						loadedarrows.erase(arrow)
						arrow.visible = false
						combo += 1 #increment combo
						get_node("combotext").text = str(combo) + " combo"
					else:
						ignoredarrows.append(arrow)
						combo = 0 #reset combo
						get_node("combotext").text = ""
					#set text and change color
					get_node("reactiontext").text = check[1]
					get_node("reactiontext").add_color_override("font_color", check[3])
					if firsthitoffsetflag == false:
						var maxdif = arrow.position[1]-center
						for arrow2 in loadedarrows:
							if arrow2.position[1] != arrow.position[1]:
								arrow2.position[1] = arrow2.position[1] + maxdif
						firsthitoffsetflag = true
					break
		
		
#creates base arrows
func createbase(arrowcount):
	#clear existing arrows if calling from another location than ready
	for arrow in basearrows:
		remove_child(arrow)
		basearrows.erase(arrow)
	#set loop count and base offset
	var loopcount = 1
	var basepos = 32
	#loop x times according to argument
	#creates an arrow per loop, puts it in basearrows, sets the name properly, sets the position
	for base in arrowcount:
		positions.append(basepos)
		var arrow = arrowins.instance();
		add_child(arrow)
		arrow.position = Vector2(basepos, 32)
		arrow.name = "arrow_base" + str(loopcount)
		basearrows.append(arrow)
		arrow.get_node("arrow_image").texture = load(positionimage[loopcount-1])
		loopcount+=1
		basepos+=80

func load_combo(file2):
	var f = File.new()
	f.open(file2, File.READ) 
	var options = f.get_as_text().split(";")
	#load options data into memory
	for option in options:
		var opt = option.split("=")[0].to_lower().strip_edges()
		match opt:
			"game":
				gamename = option.split("=")[1]
			"comboname":
				comboname = option.split("=")[1]
			"framerate":
				framerate = option.split("=")[1]
				Engine.target_fps = int(framerate)
			"charactername":
				charactername = option.split("=")[1]
			"combodata":
				var tempcombostring = option.split("=")[1]
				combostring = evaluate(tempcombostring)
				#load the used buttons into combo inputs
				for line in combostring:
					for input in line[0]:
						if !(input in comboinputs):
							comboinputs.append(input)
				#set the number of arrows equal to the number of used inputs
				var orderedcomboinputs = []
				#order the combo inputs in proper l2r order
				arrowbasecount = comboinputs.size()
				for input in ordered_inputs:
					if input in comboinputs:
						orderedcomboinputs.append(input)
				comboinputs = orderedcomboinputs
				#set images
				var index = 0
				var prefKeys = settings.buttonBinds
				#bind reset
				for key in prefKeys:
					if key[0] == "RESET":
						InputMap.erase_action("ui_reset")
						InputMap.add_action("ui_reset")
						var bind = InputEvent.new()
						if key[1][0] == "InputEventKey":
							bind = InputEventKey.new()
							bind.scancode = key[1][1]
						elif key[1][0] == "InputEventJoypadButton":
							bind = InputEventJoypadButton.new()
							bind.button_index = key[1][1]
						elif key[1][0] == "InputEventJoypadMotion":
							bind = InputEventJoypadMotion.new()
							bind.axis = key[1][1]
							bind.axis_value = key[1][2]
						InputMap.action_add_event("ui_reset", bind)
				
				for input in comboinputs:
					#set images
					positionimage[index] = 'res://Arrows/arrow_'+str(input).to_lower()+'.png'
					index+=1
					#set keys
					for key in prefKeys:
						if key[0] == input:
							InputMap.erase_action("ui_arrow"+str(index))
							InputMap.add_action("ui_arrow"+str(index))
							var bind = InputEvent.new()
							if key[1][0] == "InputEventKey":
								bind = InputEventKey.new()
								bind.scancode = key[1][1]
							elif key[1][0] == "InputEventJoypadButton":
								bind = InputEventJoypadButton.new()
								bind.button_index = key[1][1]
							elif key[1][0] == "InputEventJoypadMotion":
								bind = InputEventJoypadMotion.new()
								bind.axis = key[1][1]
								bind.axis_value = key[1][2]
							InputMap.action_add_event("ui_arrow"+str(index), bind)
			_:
				pass
	f.close()
	#set text on screen
	$comboInfo.set_text("Game: "+gamename+"\nCharacter: "+charactername+"\nCombo: "+comboname)
	return

func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()

	var obj = Reference.new()
	obj.set_script(script)

	return obj.eval() # Supposing input is "23 + 2", returns 25

func reset(): 
	for i in 4:
		for arrow in loadedarrows:
			loadedarrows.erase(arrow)
			ignoredarrows.erase(arrow)
			unsoundedarrows.erase(arrow)
			remove_child(arrow)
	currentframe = -10
	firsthitoffsetflag = false
	combo = 0
	get_node("reactiontext").text = "" #clear text
	get_node("combotext").text = "" #clear text
