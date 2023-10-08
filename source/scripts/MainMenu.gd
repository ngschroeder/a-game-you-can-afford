extends Node

# Save and load stuff

# Misc
var screen = "title"
var slideSpeed = 80
var playbackPos

# Screen Size Option Vars
var displayOptions = {}
var currentDisplaySetting
var newDisplaySetting
var newWidth
var newHeight
var newScale
var newFullscreen
var settingImgPath
var createSave

func _init():
	print(OS.get_user_data_dir())

func _ready():
	if Globals.demoBuild == true:
		get_node("MainWindow/MainImage").texture = load("res://art/title-16-demo.png")
	var err = Globals.settingsSaveInstance.load(Globals.settings_path)
	if err == OK:
		print("Save file found, loading settings.")
		Globals.load_settings()
	else:
		Globals.create_save()

	if get_window().get_size().x != float(Globals.currentWidth):
		Globals.resize_game(int(Globals.currentWidth),int(Globals.currentHeight),float(Globals.currentScale),Globals.fullscreenEnabled)
	if Globals.continueEnabled == true:
		get_node("MainWindow/MainImage/Continue").visible = true
	if Globals.endingsSeen.is_empty() != true:
		get_node("MainWindow/MainImage/Endings").visible = true

	# Display Options
	displayOptions = loadDictionary("res://files/displayoptions.tres")

	settingImgPath = "res://art/menu/" + str(Globals.currentWidth) + ".png"
	get_node("MainWindow/OptionImage/Size/SizeSelection").texture = load(settingImgPath)
	get_node("MainWindow/OptionImage/SizeApply").visible = false
	# Other Options
	get_node("MainWindow/OptionImage/Sound/SoundBox/Check").visible = Globals.soundEnabled
	get_node("MainWindow/OptionImage/Telemetry/TelemetryBox/Check").visible = Globals.telemetryEnabled
	get_node("MainWindow/OptionImage/Hardcore/HardcoreBox/Check").visible = Globals.hardcodeEnabled
	if Globals.customMouseSize == "default":
		Globals.set_mousepointer()
	else:
		Globals.set_mouse_manual(Globals.customMouseSize)
		var mouseImgPath = "res://art/menu/" + str(Globals.customMouseSize) + ".png"
		get_node("MainWindow/OptionImage/Mouse/MouseSelection").texture = load(mouseImgPath)
	if Globals.startMainMenuOnOptions == true:
		var mainImage = get_node("MainWindow/MainImage")
		var optionImage = get_node("MainWindow/OptionImage")
		while optionImage.position.x > 0:
			optionImage.position.x = (optionImage.position.x - slideSpeed)
			mainImage.position.x = (mainImage.position.x - slideSpeed)
		screen = "option"
	play_intro()
	if !Globals.gameStarted:
		Globals.update_size()
	unlockEndings()
	print("Startup scale: ", Globals.currentScale)
	if Globals.demoBuild == true:
		get_node("MainWindow/OptionImage/Hardcore").visible = false
		get_node("MainWindow/MainImage/Continue").visible = false
	if Globals.endingScreenLaunch == true:
		var mainImage = get_node("MainWindow/MainImage")
		var endingImage = get_node("MainWindow/EndingImage")
		endingImage.position.x = 0
		mainImage.position.x = 1280
		screen = "ending"
		Globals.endingScreenLaunch = false
	Globals.gameStarted = true
	

func unlockEndings():
	var endingNodes = get_node("MainWindow/EndingImage").get_children()
	for i in endingNodes:
		if i.name == "1" or i.name == "2" or i.name == "3" or i.name == "4" or i.name == "5" or i.name == "6" or i.name == "7" or i.name == "8" or i.name == "9" or i.name == "10":
			if Globals.endingsSeen.has(int(str(i.name))):
				var fileName = "res://art/endingthumbs/" + i.name + ".png"
				i.texture = load(fileName)
				i.modulate = Color(0.5,0.5,0.5)

# New Game Button
func _on_NewGame_mouse_entered():
	var newGameImage = get_node("MainWindow/MainImage/NewGame")
	newGameImage.texture = load("res://art/menu/new-game-highlight.png")

func _on_NewGame_mouse_exited():
	var newGameImage = get_node("MainWindow/MainImage/NewGame")
	newGameImage.texture = load("res://art/menu/new-game.png")

func _on_NewGame_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.setNewGameVars()
			Globals.hungerTimer()
			var error_code = get_tree().change_scene_to_file("res://scenes/Apartment-Int.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_Options_mouse_entered():
	var optionsImage = get_node("MainWindow/MainImage/Options")
	optionsImage.texture = load("res://art/menu/options-highlight.png")

func _on_Options_mouse_exited():
	var optionsImage = get_node("MainWindow/MainImage/Options")
	optionsImage.texture = load("res://art/menu/options.png")

func _on_Continue_mouse_entered():
	var continueImage = get_node("MainWindow/MainImage/Continue")
	continueImage.texture = load("res://art/menu/continue-highlight.png")

func _on_Continue_mouse_exited():
	var continueImage = get_node("MainWindow/MainImage/Continue")
	continueImage.texture = load("res://art/menu/continue.png")

func _on_Back_mouse_entered():
	var backImage = get_node("MainWindow/OptionImage/Back")
	backImage.texture = load("res://art/menu/main-menu-highlight.png")

func _on_Back_mouse_exited():
	var backImage = get_node("MainWindow/OptionImage/Back")
	backImage.texture = load("res://art/menu/main-menu.png")

func _on_Options_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			slideOption()

func _on_Back_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			slideOption()

func slideOption():
	if screen == "title":
		var mainImage = get_node("MainWindow/MainImage")
		var optionImage = get_node("MainWindow/OptionImage")
		while optionImage.position.x > 0:
			optionImage.position.x = (optionImage.position.x - slideSpeed)
			mainImage.position.x = (mainImage.position.x - slideSpeed)
			await get_tree().create_timer(0.01).timeout
		screen = "option"
		return
	if screen == "option":
		var mainImage = get_node("MainWindow/MainImage")
		var optionImage = get_node("MainWindow/OptionImage")
		while mainImage.position.x < 0:
			optionImage.position.x = (optionImage.position.x + slideSpeed)
			mainImage.position.x = (mainImage.position.x + slideSpeed)
			await get_tree().create_timer(0.01).timeout
		screen = "title"
		return

func slideEndings():
	if screen == "title":
		var mainImage = get_node("MainWindow/MainImage")
		var endingImage = get_node("MainWindow/EndingImage")
		while endingImage.position.x < 0:
			endingImage.position.x = (endingImage.position.x + slideSpeed)
			mainImage.position.x = (mainImage.position.x + slideSpeed)
			await get_tree().create_timer(0.01).timeout
		screen = "ending"
		return
	if screen == "ending":
		var mainImage = get_node("MainWindow/MainImage")
		var endingImage = get_node("MainWindow/EndingImage")
		while mainImage.position.x > 0:
			endingImage.position.x = (endingImage.position.x - slideSpeed)
			mainImage.position.x = (mainImage.position.x - slideSpeed)
			await get_tree().create_timer(0.01).timeout
		screen = "title"
		return

# Resize Options
func _on_Size_mouse_entered():
	var sizeImage = get_node("MainWindow/OptionImage/Size")
	sizeImage.texture = load("res://art/menu/screensize-highlight.png")

func _on_Size_mouse_exited():
	var sizeImage = get_node("MainWindow/OptionImage/Size")
	sizeImage.texture = load("res://art/menu/screensize.png")

func _on_Size_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			newDisplaySetting = 0
			if currentDisplaySetting != newDisplaySetting:
				get_node("MainWindow/OptionImage/SizeApply").visible = true
			else:
				get_node("MainWindow/OptionImage/SizeApply").visible = false
			newWidth = displayOptions[str(newDisplaySetting)][0]["newWidth"]
			newHeight = displayOptions[str(newDisplaySetting)][1]["newHeight"]
			newScale = displayOptions[str(newDisplaySetting)][2]["newScale"]
			newFullscreen = displayOptions[str(newDisplaySetting)][3]["newFullscreen"]
			if newFullscreen == "true":
				settingImgPath = "res://art/menu/fullscreen.png"
			else:
				settingImgPath = "res://art/menu/" + newWidth + ".png"
			get_node("MainWindow/OptionImage/Size/SizeSelection").texture = load(settingImgPath)

func _on_SizeApply_mouse_entered():
	var sizeImage = get_node("MainWindow/OptionImage/SizeApply")
	sizeImage.texture = load("res://art/menu/apply-highlight.png")

func _on_SizeApply_mouse_exited():
	var sizeImage = get_node("MainWindow/OptionImage/SizeApply")
	sizeImage.texture = load("res://art/menu/apply.png")

func _on_SizeApply_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			Globals.resize_game(int(newWidth),int(newHeight),float(newScale),newFullscreen)
			currentDisplaySetting = newDisplaySetting
			Globals.saveSetting("settings", "currentWidth", newWidth)
			Globals.saveSetting("settings", "currentHeight", newHeight)
			Globals.saveSetting("settings", "currentScale", newScale)
			print(newWidth,newHeight,newScale,newFullscreen)
			Globals.saveSetting("settings", "fullscreenEnabled", newFullscreen)
			get_node("MainWindow/OptionImage/SizeApply").visible = false
			get_node("MainWindow/OptionImage/SizeApply").texture = load("res://art/menu/apply.png")

func load_json_file(path):
	var file
	file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(text)
	var result_json = test_json_conv.get_data()
	if test_json_conv.get_error_line() != OK:
		print("[load_json_file] Error loading JSON file '" + str(path) + "'.")
		print("\tError: ", result_json.error)
		print("\tError Line: ", result_json.error_line)
		print("\tError String: ", result_json.error_string)
		return null
	var obj = result_json
	return obj

func loadDictionary(path):
	var my_json = JSON.new()
	var file = FileAccess.open(path, FileAccess.READ)	
	var jsonText = file.get_as_text()
	var parse_result = my_json.parse(jsonText)
	if parse_result != OK:
		print("Error %s reading json file." % parse_result)
		return
	var data = my_json.get_data()
	file.close()
	return data

# Sound Option Controls
func _on_Sound_mouse_entered():
	get_node("MainWindow/OptionImage/Sound").texture = load("res://art/menu/sound-highlight.png")

func _on_Sound_mouse_exited():
	get_node("MainWindow/OptionImage/Sound").texture = load("res://art/menu/sound.png")

func _on_Sound_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			Globals.soundEnabled = !Globals.soundEnabled
			Globals.saveSetting("settings", "soundEnabled", Globals.soundEnabled)
			get_node("MainWindow/OptionImage/Sound/SoundBox/Check").visible = Globals.soundEnabled
			if Globals.soundEnabled == true:
				Globals.getSceneNode().get_node("AudioStreamPlayer").play()
				if playbackPos != null:
					Globals.getSceneNode().get_node("AudioStreamPlayer").seek(playbackPos)
			else:
				playbackPos = Globals.getSceneNode().get_node("AudioStreamPlayer").get_playback_position()
				Globals.getSceneNode().get_node("AudioStreamPlayer").stop()

# Hardcore Option Controls
func _on_Hardcore_mouse_entered():
	get_node("MainWindow/OptionImage/Hardcore").texture = load("res://art/menu/hardcore-highlight.png")

func _on_Hardcore_mouse_exited():
	get_node("MainWindow/OptionImage/Hardcore").texture = load("res://art/menu/hardcore.png")

func _on_Hardcore_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			Globals.hardcodeEnabled = !Globals.hardcodeEnabled
			get_node("MainWindow/OptionImage/Hardcore/HardcoreBox/Check").visible = Globals.hardcodeEnabled

# Telemetry Option Controls
func _on_Telemetry_mouse_entered():
	get_node("MainWindow/OptionImage/Telemetry").texture = load("res://art/menu/telemetry-highlight.png")

func _on_Telemetry_mouse_exited():
	get_node("MainWindow/OptionImage/Telemetry").texture = load("res://art/menu/telemetry.png")

func _on_Telemetry_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed:
			Globals.telemetryEnabled = !Globals.telemetryEnabled
			Globals.saveSetting("settings", "telemetryEnabled", Globals.telemetryEnabled)
			get_node("MainWindow/OptionImage/Telemetry/TelemetryBox/Check").visible = Globals.telemetryEnabled

func _on_Help_mouse_entered():
	get_node("MainWindow/OptionImage/Help").texture = load("res://art/menu/help-highlight.png")

func _on_Help_mouse_exited():
	get_node("MainWindow/OptionImage/Help").texture = load("res://art/menu/help.png")

func _on_Credits_mouse_entered():
	get_node("MainWindow/OptionImage/Credits").texture = load("res://art/menu/credits-highlight.png")

func _on_Credits_mouse_exited():
	get_node("MainWindow/OptionImage/Credits").texture = load("res://art/menu/credits.png")

func _on_Credits_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var error_code = get_tree().change_scene_to_file("res://scenes/Credits.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func play_intro():
	var audioNode = Globals.getSceneNode().get_node("AudioStreamPlayer")
	var sound : AudioStream = load("res://sounds/newintro.wav")
	audioNode.set_stream(sound)
	if Globals.soundEnabled == true:
		audioNode.play()

func stop_intro():
	var audioNode = Globals.getSceneNode().get_node("AudioStreamPlayer")
	audioNode.stop()

func _on_Help_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("MainWindow/OptionImage/HelpContainer").visible = true

func _on_HelpContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("MainWindow/OptionImage/HelpContainer").visible = false

func _on_Continue_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.loadLastSave()
			Globals.continueInProgress = true
			var loadScene = "res://scenes/" + Globals.currentLocation + ".tscn" 
			print(loadScene)
			Globals.hungerMinutes = 0
			Globals.hungerTimer()
			var error_code = get_tree().change_scene_to_file(loadScene)
			if error_code != 0:
				print("ERROR: ", error_code)


func _on_Endings_mouse_entered():
	var endingsImage = get_node("MainWindow/MainImage/Endings")
	endingsImage.texture = load("res://art/menu/endings-highlight.png")


func _on_Endings_mouse_exited():
	var endingsImage = get_node("MainWindow/MainImage/Endings")
	endingsImage.texture = load("res://art/menu/endings.png")


func _on_Endings_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			slideEndings()

func _on_1_mouse_entered():
	if Globals.endingsSeen.has(1):
		get_node("MainWindow/EndingImage/1").modulate = Color(1.1,1.1,1.1)


func _on_1_mouse_exited():
	if Globals.endingsSeen.has(1):
		get_node("MainWindow/EndingImage/1").modulate = Color(0.5,0.5,0.5)

func _on_1_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 1
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_2_mouse_entered():
	if Globals.endingsSeen.has(2):
		get_node("MainWindow/EndingImage/2").modulate = Color(1.1,1.1,1.1)

func _on_2_mouse_exited():
	if Globals.endingsSeen.has(2):
		get_node("MainWindow/EndingImage/2").modulate = Color(0.5,0.5,0.5)

func _on_2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 2
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_3_mouse_entered():
	if Globals.endingsSeen.has(3):
		get_node("MainWindow/EndingImage/3").modulate = Color(1.1,1.1,1.1)

func _on_3_mouse_exited():
	if Globals.endingsSeen.has(3):
		get_node("MainWindow/EndingImage/3").modulate = Color(0.5,0.5,0.5)
		
func _on_3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 3
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)
				
func _on_4_mouse_entered():
	if Globals.endingsSeen.has(4):
		get_node("MainWindow/EndingImage/4").modulate = Color(1.1,1.1,1.1)

func _on_4_mouse_exited():
	if Globals.endingsSeen.has(4):
		get_node("MainWindow/EndingImage/4").modulate = Color(0.5,0.5,0.5)

func _on_4_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 4
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_5_mouse_entered():
	if Globals.endingsSeen.has(5):
		get_node("MainWindow/EndingImage/5").modulate = Color(1.1,1.1,1.1)

func _on_5_mouse_exited():
	if Globals.endingsSeen.has(5):
		get_node("MainWindow/EndingImage/5").modulate = Color(0.5,0.5,0.5)

func _on_5_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 5
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_6_mouse_entered():
	if Globals.endingsSeen.has(6):
		get_node("MainWindow/EndingImage/6").modulate = Color(1.1,1.1,1.1)

func _on_6_mouse_exited():
	if Globals.endingsSeen.has(6):
		get_node("MainWindow/EndingImage/6").modulate = Color(0.5,0.5,0.5)

func _on_6_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 6
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_7_mouse_entered():
	if Globals.endingsSeen.has(7):
		get_node("MainWindow/EndingImage/7").modulate = Color(1.1,1.1,1.1)

func _on_7_mouse_exited():
	if Globals.endingsSeen.has(7):
		get_node("MainWindow/EndingImage/7").modulate = Color(0.5,0.5,0.5)

func _on_7_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 7
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_8_mouse_entered():
	if Globals.endingsSeen.has(8):
		get_node("MainWindow/EndingImage/8").modulate = Color(1.1,1.1,1.1)

func _on_8_mouse_exited():
	if Globals.endingsSeen.has(8):
		get_node("MainWindow/EndingImage/8").modulate = Color(0.5,0.5,0.5)

func _on_8_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 8
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_9_mouse_entered():
	if Globals.endingsSeen.has(9):
		get_node("MainWindow/EndingImage/9").modulate = Color(1.1,1.1,1.1)

func _on_9_mouse_exited():
	if Globals.endingsSeen.has(9):
		get_node("MainWindow/EndingImage/9").modulate = Color(0.5,0.5,0.5)

func _on_9_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 9
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_10_mouse_entered():
	if Globals.endingsSeen.has(10):
		get_node("MainWindow/EndingImage/10").modulate = Color(1.1,1.1,1.1)

func _on_10_mouse_exited():
	if Globals.endingsSeen.has(10):
		get_node("MainWindow/EndingImage/10").modulate = Color(0.5,0.5,0.5)

func _on_10_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.endingScreenLaunch = true
			Globals.currentEnding = 10
			var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_EndingBack_mouse_entered():
	var endingBack = get_node("MainWindow/EndingImage/Container/EndingBack")
	endingBack.texture = load("res://art/menu/endingback-highlight.png")

func _on_EndingBack_mouse_exited():
	var endingBack = get_node("MainWindow/EndingImage/Container/EndingBack")
	endingBack.texture = load("res://art/menu/endingback.png")

func _on_EndingBack_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			slideEndings()

func _on_Mouse_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.cycle_mouse()

func _on_Mouse_mouse_entered():
	get_node("MainWindow/OptionImage/Mouse").texture = load("res://art/menu/mousesize-highlight.png")

func _on_Mouse_mouse_exited():
	get_node("MainWindow/OptionImage/Mouse").texture = load("res://art/menu/mousesize.png")
