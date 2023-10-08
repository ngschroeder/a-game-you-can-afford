extends Node

var allowed_characters = "[A-Za-z0-9_]"
var click_style = StyleBoxFlat.new()
var default_style = null
var settingsNode

func _ready():
	click_style.set_bg_color(Color(1,1,1))
	default_style = get_node("SaveWindow/InnerWindow/Back/Text").get("theme_override_styles/normal")

func _on_FileName_text_changed(new_text):
	var fileName = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileName")
	var old_caret_position = fileName.caret_column
	var word = ''
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	fileName.set_text(word)
	fileName.caret_column = old_caret_position

func createSettings():
	var settingsNode = load("res://scenes/Settings.tscn").instantiate()
	var settingsPosition = Vector2(400,150)
	settingsNode.set_position(settingsPosition)
	Globals.getSceneNode().get_node("MainWindow/LocationImage").add_child(settingsNode)
	var loadedNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Settings/SaveWindow")
	loadedNode.visible = false

func get_sorted_file_list():
	var files = Globals.list_files_in_directory(Globals.save_dir)
	var fileAgeDict = {}
	var fileAgeArray = []
	var finalList = []
	finalList.resize(files.size())
	for i in files:
		var age = FileAccess.get_modified_time(Globals.save_dir + i)
		fileAgeArray.append(age)
		fileAgeDict[str(age)] = i
	fileAgeArray.sort()
	var n = files.size()
	var c = 0
	while n > 0:
		var thisPos = fileAgeArray.size() - (c + 1)
		var thisKey = str(fileAgeArray[thisPos])
		finalList[c] = fileAgeDict[thisKey]
		c += 1
		n -= 1
	return finalList

func getSaves():
	var files = get_sorted_file_list()
	var listWindow = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileList")
	var fileBBText = ""
	var i = 0
	while i < files.size():
		var line = "[url=" + str(files[i]) + "]" + str(files[i])
		var n = 0
		var blanks = 14 - files[i].length()
		while n < blanks:
			line = line + " "
			n += 1
		line = line + "[/url]"
		if i != files.size() - 1:
			line = line + "\n"
		fileBBText = fileBBText + line
		i += 1
	listWindow.text = str(fileBBText)
	listWindow.connect("meta_clicked", Callable(self, "click_save_file"))

func remove_bbcode(input_string):
	var output_string = ""
	var i = 0
	while i < input_string.length():
		if input_string[i] == "[":
			var j = i + 1
			while j < input_string.length() and input_string[j] != "]":
				j += 1
			if j < input_string.length():
				i = j + 1
		else:
			output_string = output_string + input_string[i]
			i += 1
	return output_string

func click_save_file(data):
	var fileName = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileName")
	var fileList = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileList").get_text()
	var listItems = fileList.split("\n")
	var i = 0
	while i < listItems.size():
		var thisText = remove_bbcode(listItems[i]).replace(" ","")
		if data == thisText:
			listItems[i] = "[b]" + listItems[i] + "[/b]"
		else:
			listItems[i] = listItems[i].replace("[b]","").replace("[/b]","")
		i += 1
	var newString = ""
	var n = 0
	while n < listItems.size():
		newString = newString + listItems[n]
		if n != listItems.size() - 1:
			newString = newString + "\n"
		n += 1
	Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileList").set_text(newString)
	fileName.text = data

func _on_Back_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("SaveWindow/InnerWindow/Back/Text").add_theme_color_override("font_color", Color(0, 0, 0))
			get_node("SaveWindow/InnerWindow/Back/Text").set("theme_override_styles/normal", click_style)
		if event.button_index == 1 and !event.pressed:
			get_node("SaveWindow/InnerWindow/Back/Text").add_theme_color_override("font_color", Color(1, 1, 1))
			get_node("SaveWindow/InnerWindow/Back/Text").set("theme_override_styles/normal", default_style)
			await get_tree().create_timer(0.1).timeout
			Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
			var settingsNode = get_node("SaveWindow")
			settingsNode.visible = false
			Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window").visible = false
			Globals.inventoryOpen = false
			Globals.closeZoomOnClick = false

func _on_Save_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("SaveWindow/InnerWindow/Save/Text").add_theme_color_override("font_color", Color(0, 0, 0))
			get_node("SaveWindow/InnerWindow/Save/Text").set("theme_override_styles/normal", click_style)
		if event.button_index == 1 and !event.pressed:
			get_node("SaveWindow/InnerWindow/Save/Text").add_theme_color_override("font_color", Color(1, 1, 1))
			get_node("SaveWindow/InnerWindow/Save/Text").set("theme_override_styles/normal", default_style)
			await get_tree().create_timer(0.1).timeout
			var fileName = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileName").text
			if fileName == "":
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/Warning").text = "Warning:\nNo file name!"
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/Warning").visible = true
			else: 
				var savePath = Globals.save_dir + fileName
				print(savePath)
				Globals.save_game_data(savePath)
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileName").text = ""
				getSaves()

func _on_Load_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("SaveWindow/InnerWindow/Load/Text").add_theme_color_override("font_color", Color(0, 0, 0))
			get_node("SaveWindow/InnerWindow/Load/Text").set("theme_override_styles/normal", click_style)

		if event.button_index == 1 and !event.pressed:
			get_node("SaveWindow/InnerWindow/Load/Text").add_theme_color_override("font_color", Color(1, 1, 1))
			get_node("SaveWindow/InnerWindow/Load/Text").set("theme_override_styles/normal", default_style)
			await get_tree().create_timer(0.1).timeout
			var fileName = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileName").text
			if fileName == "":
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/Warning").text = "Warning:\nNo file name!"
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/Warning").visible = true
			else:
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window").visible = false
				var savePath = Globals.save_dir + fileName
				Globals.load_game_data(savePath)
				var loadScene = "res://scenes/" + Globals.currentLocation + ".tscn" 
				Globals.inventoryOpen = false
				Globals.closeZoomOnClick = false
				Globals.continueInProgress = true
				Globals.hungerMinutes = 0
				Globals.hungerTimer()
				var error_code = get_tree().change_scene_to_file(loadScene)
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_Delete_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("SaveWindow/InnerWindow/Delete/Text").add_theme_color_override("font_color", Color(0, 0, 0))
			get_node("SaveWindow/InnerWindow/Delete/Text").set("theme_override_styles/normal", click_style)
		if event.button_index == 1 and !event.pressed:
			get_node("SaveWindow/InnerWindow/Delete/Text").add_theme_color_override("font_color", Color(1, 1, 1))
			get_node("SaveWindow/InnerWindow/Delete/Text").set("theme_override_styles/normal", default_style)
			await get_tree().create_timer(0.1).timeout
			var fileName = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow/InnerWindow/FileName").text
			DirAccess.remove_absolute(Globals.save_dir + fileName)
			getSaves()

func _on_Quit_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			get_node("SaveWindow/InnerWindow/Quit/Text").add_theme_color_override("font_color", Color(0, 0, 0))
			get_node("SaveWindow/InnerWindow/Quit/Text").set("theme_override_styles/normal", click_style)
		if event.button_index == 1 and !event.pressed:
			get_node("SaveWindow/InnerWindow/Quit/Text").add_theme_color_override("font_color", Color(1, 1, 1))
			get_node("SaveWindow/InnerWindow/Quit/Text").set("theme_override_styles/normal", default_style)
			await get_tree().create_timer(0.1).timeout
			var error_code = get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)
