extends Node

var dawnSpeed = 1.2
var messageWindowInstance = Globals.MessageWindow.new()
var inventoryPackInstance = Globals.InventoryInstance.new()
var lightSwitchHovered
var ramenClicked = false

func _ready():
	# Set brightness
	var material = $MainWindow/LocationImage.material as ShaderMaterial
	material.set_shader_parameter("darkness", 1.0)
	Globals.update_size()
	Globals.currentLocation = Globals.getLocationName()
	if Globals.apartmentLightOn == true:
		_set_light_room()
	else:
		_set_dark_room()
	lightSwitchHovered = false
	if Globals.newGame == true:
		Globals.play_alarm()
		messageWindowInstance.details_message_window("NewGame", "misc")
		Globals.newGame = false
	if Globals.hasRamen == true or Globals.usedRamen == true:
		get_node("MainWindow/LocationImage/Interactives/Ramen").visible = false
	if Globals.computerPlaced == true:
		get_node("MainWindow/LocationImage/Interactives/Laptop").visible = true
	var location = Globals.getLocationName()
	if location != "MainMenu":
		inventoryPackInstance.createInventory()

# This is the top-level click event and is used to close all dialogs and other stuff if anything is open, to prevent e.g. being
# able to click on an item and pick it up in the middle of my brilliant exposition on the futility of modern life.
func _input(event):
	if event is InputEventMouseButton:
		if Globals.clickDisabled == true:
			get_viewport().set_input_as_handled()
		if event.button_index == 1 and event.pressed:
			if Globals.apartmentLightOn == false and lightSwitchHovered == false and Globals.messageWindowOpen == false and Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible == false:
				messageWindowInstance.details_message_window("AnyClickDark", "misc")
				get_viewport().set_input_as_handled()
			if event.button_index == 1 and event.pressed and get_node("MainWindow/LocationImage/Interactives/BabyPic").visible == true:
				get_node("MainWindow/LocationImage/Interactives/BabyPic").visible = false
				get_viewport().set_input_as_handled()
		if event.button_index == 2 and event.pressed and get_node("MainWindow/LocationImage/Interactives/BabyPic").visible == true:
			get_node("MainWindow/LocationImage/Interactives/BabyPic").visible = false
			get_viewport().set_input_as_handled()

# Hover Actions
func _on_LightSwitch_mouse_entered():
	lightSwitchHovered = true

func _on_LightSwitch_mouse_exited():
	lightSwitchHovered = false

func _on_ExitField_mouse_entered():
	if Globals.apartmentLightOn == true and Globals.messageWindowOpen == false and Globals.itemCursor == null:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitField_mouse_exited():
	if Globals.apartmentLightOn == true and Globals.messageWindowOpen == false and Globals.itemCursor == null:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

# This is needed to reset the cursor when the player leaves the room
func _on_ExitField_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

# Nice effect if the player wakes up at sunrise
func _morning_wake():
	var currentBrightness = 0.1
	get_node("MainWindow/LocationImage").modulate = Color(0.1,0.1,0.1)
	while currentBrightness < 1:
		currentBrightness = currentBrightness * dawnSpeed
		get_node("MainWindow/LocationImage").modulate = Color(currentBrightness,currentBrightness,currentBrightness)
		await get_tree().create_timer(1).timeout
	Globals.apartmentLightOn = true

# Clickable Events
# Items must have mouse enter/exit functions to set Globals.itemObjectHover to true!

# Light Switch
func _on_LightSwitch_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and Globals.messageWindowOpen == false and !event.pressed and Globals.inventoryOpen == false:
			if Globals.apartmentLightOn == false:
				_set_light_room()
				if Globals.locationsSeen.has(Globals.getLocationName()) == false:
					messageWindowInstance.details_message_window(str(Globals.getLocationName()), "location")
					Globals.locationsSeen[Globals.getLocationName()] = true
					get_viewport().set_input_as_handled()
			elif Globals.apartmentLightOn == true:
				_set_dark_room()
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed:
			if Globals.apartmentLightOn == false:
				messageWindowInstance.details_message_window("LightSwitchDark", "misc")
			else:
				var itemNode = get_node("MainWindow/LocationImage/Interactives/LightSwitch")
				messageWindowInstance.details_message_window(itemNode, "object")

# Ramen
func _on_Ramen_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Ramen")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				itemNode.visible = false
				messageWindowInstance.item_message_window(itemNode)
				Globals.hasRamen = true
				(Globals.inventory).append(itemNode.name)
			if event.button_index == 1 and event.pressed:
				messageWindowInstance.details_message_window(itemNode, "object")

# Note
func _on_Note_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Note")
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
				Globals.mapLocationsUnlocked["Vastmart"] = true
				Globals.mapLocationsUnlocked["PumpsUp"] = true
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window("NoteBack", "misc")


func _on_Bed_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Bed")
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				if Globals.pumpsupShiftOver == true:
					if Globals.gotComputer == true:
						Globals.messageWindowInstance.details_message_window("BedChoice", "misc")
						var answer = await Globals.choiceMade
						if answer == "0":
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
							_set_dark_room()
							Globals.messageWindowInstance.details_message_window("Bedtime", "misc")
							await Globals.textComplete
							init_ending()
						else:
							Globals.messageWindowInstance.details_message_window("BedNevermind", "misc")
					else:
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
						Globals.messageWindowInstance.details_message_window("Bedtime", "misc")
						await Globals.textComplete
						init_ending()
				else:
					messageWindowInstance.details_message_window(itemNode, "misc")

func _on_Desk_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Desk")
			if event.button_index == 1 and event.pressed and Globals.itemCursor == "laptop":
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				Globals.inventory.erase("Laptop")
				get_node("MainWindow/LocationImage/Interactives/Laptop").visible = true
				messageWindowInstance.details_message_window("LaptopSetup", "misc")
				await Globals.textComplete
				Globals.computerPlaced = true
				return
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "misc")

func _on_Microwave_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Microwave")
			if event.button_index == 1 and event.pressed and Globals.itemCursor == "ramen":
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				if Globals.ramenWaterAdded == true:
					Globals.inventory.erase("Ramen")
					Globals.usedRamen = true
					Globals.itemCursor = null
					Input.set_custom_mouse_cursor(Globals.pointerarrow)
					itemNode.texture = load("res://art/object/microwave-on.png")
					messageWindowInstance.details_message_window("RamenInMicrowave", "misc")
					await Globals.textComplete
					await get_tree().create_timer(1).timeout
					itemNode.texture = load("res://art/object/microwave.png")
					# playsound BING!
					messageWindowInstance.details_message_window("RamenWithWater", "misc")
				else:
					# Microwave catches fire
					Globals.currentEnding = 1
					itemNode.texture = load("res://art/object/microwave-on.png")
					messageWindowInstance.details_message_window("RamenInMicrowave", "misc")
					await Globals.textComplete
					await get_tree().create_timer(1).timeout
					get_node("MainWindow/LocationImage/Interactives/MicrowaveFlame").visible = true
					# This text file triggers the apartment burning down ending
					messageWindowInstance.details_message_window("RamenNoWater", "misc")
					await Globals.textComplete
					await get_tree().create_timer(1).timeout
				get_viewport().set_input_as_handled()
				return
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "misc")

func _on_Sink_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Sink")
			if event.button_index == 1 and event.pressed and Globals.itemCursor == "ramen":
				Globals.ramenWaterAdded = true
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				messageWindowInstance.details_message_window("SinkRamen", "misc")
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and (Globals.handsClean == false or Globals.faceClean == false):
				messageWindowInstance.details_message_window("WashElsewhere", "misc")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "misc")

func _on_Cabinets_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Cabinets")
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "misc")

# Exit to Apartment-Ext
func _on_ExitField_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				var error_code = get_tree().change_scene_to_file("res://scenes/Apartment-Ext.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

# Room Light Controls
func _set_dark_room():
	var material = $MainWindow/LocationImage.material as ShaderMaterial
	material.set_shader_parameter("darkness", 0.25)
	Globals.apartmentLightOn = false
	var childNodes = $MainWindow/LocationImage/Interactives.get_children()
	for child in childNodes:
		if child is TextureRect:
			var childMaterial = child.material as ShaderMaterial
			if childMaterial:
				childMaterial.set_shader_parameter("darkness", 0.25)

func _set_light_room():
	var material = $MainWindow/LocationImage.material as ShaderMaterial
	material.set_shader_parameter("darkness", 1)
	Globals.apartmentLightOn = true
	var childNodes = $MainWindow/LocationImage/Interactives.get_children()
	for child in childNodes:
		if child is TextureRect:
			var childMaterial = child.material as ShaderMaterial
			if childMaterial:
				childMaterial.set_shader_parameter("darkness", 1)

func mouseInfo():
	print("            [Mouse Info]")
	print("            MouseLocked: ", Globals.mouseLocked)
	print("     lightSwitchHovered: ", lightSwitchHovered)
	print("      messageWindowOpen: ", Globals.messageWindowOpen)

func _on_Desk_mouse_entered():
	Globals.itemObjectHover = true
	Globals.expectedItem = "laptop"

func _on_Desk_mouse_exited():
	Globals.itemObjectHover = false
	Globals.expectedItem = null

func _on_Microwave_mouse_entered():
	Globals.itemObjectHover = true
	Globals.expectedItem = "ramen"


func _on_Microwave_mouse_exited():
	Globals.itemObjectHover = false
	Globals.expectedItem = null
	
func _on_Sink_mouse_entered():
	Globals.itemObjectHover = true
	Globals.expectedItem = "ramen"

func _on_Sink_mouse_exited():
	Globals.itemObjectHover = false
	Globals.expectedItem = null

func _on_Nightstand_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Nightstand")
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				get_node("MainWindow/LocationImage/Interactives/BabyPic").visible = true

func _on_BathExit_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				var error_code = get_tree().change_scene_to_file("res://scenes/Bathroom.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_AptWall_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/AptWall")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			messageWindowInstance.details_message_window(itemNode, "object")

func _on_Decor_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/Decor")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			messageWindowInstance.details_message_window(itemNode, "object")

func _on_AptFloor_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/AptFloor")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			messageWindowInstance.details_message_window(itemNode, "object")

func _on_Misc_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/Misc")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			messageWindowInstance.details_message_window(itemNode, "object")

func _on_Laptop_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			messageWindowInstance.details_message_window("Laptop", "misc")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
			get_node("MainWindow/LocationImage/Interactives/Note").visible = false
			get_node("MainWindow/LocationImage/Interactives/Ramen").visible = false
			get_node("MainWindow/LocationImage/Interactives/Microwave").visible = false
			get_node("MainWindow/LocationImage/Interactives/LightSwitch").visible = false
			get_node("MainWindow/LocationImage/Interactives/Laptop").visible = false
			var bgNode = get_node("MainWindow/LocationImage")
			bgNode.texture = load("res://art/misc/desk-sit.png")
			await get_tree().create_timer(0.75).timeout
			messageWindowInstance.details_message_window("LaptopSit", "misc")
			var answer = await Globals.choiceMade
			if answer == "0":
				messageWindowInstance.details_message_window("DropShipping", "misc")
				await Globals.textComplete
				init_ending()
			if answer == "1":
				messageWindowInstance.details_message_window("Streamer", "misc")
				await Globals.textComplete
				init_ending()
			if answer == "2":
				messageWindowInstance.details_message_window("GetSkills", "misc")
				await Globals.textComplete
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").position.y = 60
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").visible = true
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").get_child(0).grab_focus()
				messageWindowInstance.details_message_window("1", "quiz")
				var answer1 = await Globals.choiceMade
				messageWindowInstance.details_message_window("2", "quiz")
				await get_tree().create_timer(0.75).timeout
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").visible = true
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").get_child(0).grab_focus()
				var answer2 = await Globals.choiceMade
				messageWindowInstance.details_message_window("3", "quiz")
				await get_tree().create_timer(0.75).timeout
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").visible = true
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").get_child(0).grab_focus()
				var answer3 = await Globals.choiceMade
				Globals.getSceneNode().get_node("MainWindow/Overlay/Command").visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				messageWindowInstance.details_message_window("GetSkills2", "misc")
				await Globals.textComplete
				if answer1 == "img" and answer2 == "li" and answer3 == "href":
					print("You won.")
				init_ending("10")
				# here move the text window to the top and use the input field
				# to capture answers to /quiz/1-3.txt then do an "and" check (toLower)
				# on all 3 and give the best ending if true, else give OK ending.
			if answer == "3":
				messageWindowInstance.details_message_window("MakeGame", "misc")
				await Globals.textComplete
				# This is a kinda bad ending, it takes forever for you to get your game going
				# and when you do, you learn it costs money to publish. You scrape together
				# the money, publish, but have no money to advertise. And your game probably sucks.
				# You don't have enough experience to get a dev job.

###############################################################
#
# ENDING SECTION!
#
##############################################################

func init_ending(ending=null):
	if ending == "10":
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		Globals.currentEnding = 10
		Globals.do_ending(Globals.currentEnding)
		return
	if (Globals.firedFromVastmart or Globals.firedNextEntry) and Globals.pumpsupQuit:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		Globals.currentEnding = 8
		Globals.do_ending(Globals.currentEnding)
		return
	if (!Globals.firedFromVastmart or !Globals.firedNextEntry) or !Globals.pumpsupQuit:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		Globals.currentEnding = 9
		Globals.do_ending(Globals.currentEnding)
		return



###############################################################
#
# CHOICES SECTION!
#
##############################################################

func _on_Choice0_mouse_entered():
	var text = "[color=lime]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice0").text) + "[/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice0").set_bbcode(text)

func _on_Choice0_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice0").text.replace("[color=lime]","").replace("[/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice0").set_bbcode(text)

func _on_Choice0_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "0")
			Globals.choiceActive = false
			get_node("MainWindow/Overlay/MainText/Body").visible = true
			get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice1_mouse_entered():
	var text = "[color=lime]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice1").text) + "[/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice1").set_bbcode(text)

func _on_Choice1_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice1").text.replace("[color=lime]","").replace("[/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice1").set_bbcode(text)

func _on_Choice1_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "1")
			Globals.choiceActive = false
			get_node("MainWindow/Overlay/MainText/Body").visible = true
			get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice2_mouse_entered():
	var text = "[color=lime]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice2").text) + "[/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice2").set_bbcode(text)

func _on_Choice2_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice2").text.replace("[color=lime]","").replace("[/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice2").set_bbcode(text)

func _on_Choice2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "2")
			Globals.choiceActive = false
			get_node("MainWindow/Overlay/MainText/Body").visible = true
			get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice3_mouse_entered():
	var text = "[color=lime]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice3").text) + "[/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice3").set_bbcode(text)

func _on_Choice3_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice3").text.replace("[color=lime]","").replace("[/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice3").set_bbcode(text)

func _on_Choice3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "3")
			Globals.choiceActive = false
			get_node("MainWindow/Overlay/MainText/Body").visible = true
			get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice4_mouse_entered():
	var text = "[color=lime]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice4").text) + "[/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice4").set_bbcode(text)

func _on_Choice4_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice4").text.replace("[color=lime]","").replace("[/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice4").set_bbcode(text)

func _on_Choice4_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "4")
			Globals.choiceActive = false
			get_node("MainWindow/Overlay/MainText/Body").visible = true
			get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			get_node("MainWindow/Overlay/MainText/Choices").visible = false


