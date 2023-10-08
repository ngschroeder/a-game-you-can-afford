extends Node

var mapInstance = Globals.Map.new()
var inventoryPackInstance = Globals.InventoryInstance.new()
var sceneOver = false

func _ready():
	var material = $MainWindow/LocationImage.material as ShaderMaterial
	material.set_shader_parameter("darkness", 1.0)
	# Update the scale
	Globals.update_size()
	# Set the location for saving
	Globals.currentLocation = Globals.getLocationName()
	# Create the inventory
	if Globals.currentLocation != "MainMenu":
		inventoryPackInstance.createInventory()
	# If it's the first time here, describe the place
	print(Globals.locationsSeen)
	if Globals.locationsSeen.has(Globals.currentLocation) == false:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		# Pause for a moment if it's the first time here
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window(str(Globals.currentLocation), "location")
		await Globals.textComplete
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
		Globals.locationsSeen[Globals.currentLocation] = true
	if Globals.handsClean == false:
		you_filth()
		return
	if Globals.hungerMinutes >= 2:
		Globals.hungerCount += 1
		Globals.hungerCheck()
		
func you_filth():
	Globals.currentEnding = 2
	Globals.messageWindowInstance.details_message_window("Ecoli", "misc")
	await Globals.textComplete
	await get_tree().create_timer(1).timeout
	return


# This input function executes before the one in Globals and before all the GUI-based ones that come later
func _input(event):
	if event is InputEventMouseButton:
		if Globals.clickDisabled == true:
			get_viewport().set_input_as_handled()
		if event.button_index == 1 and event.pressed:
			if Globals.mapOpen == true and Globals.closeZoomOnClick == true:
				var mapNode = Globals.getSceneNode().get_node_or_null("MainWindow/LocationImage/Map/MapImage")
				if mapNode != null:
					mapNode.visible = false
					Globals.mapOpen = false
				Globals.closeZoomOnClick = false
				get_viewport().set_input_as_handled()

# Bike Functions
func _on_Bike_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.itemCursor == null:
			if Globals.playerSitting == false:
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				if Globals.bikeLocked == true:
					Globals.bikeLocked = false
					Globals.inventory.append("BikeLock")
					Globals.messageWindowInstance.details_message_window("BikeUnlocked", "misc")
					await Globals.textComplete
				mapInstance.createMap()
				Globals.mapOpen = true
				Globals.closeZoomOnClick = true
			else:
				Globals.messageWindowInstance.details_message_window("Stay", "park")
				await Globals.textComplete
		print(Globals.itemCursor)
		if event.button_index == 1 and event.pressed and Globals.itemCursor == null:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Bike")
			Globals.messageWindowInstance.details_message_window(itemNode, "object")
		if event.button_index == 1 and event.pressed and Globals.itemCursor == "bikelock":
			Globals.itemCursor = null
			Input.set_custom_mouse_cursor(Globals.pointerarrow)
			Globals.inventory.erase("BikeLock")
			Globals.bikeLocked = true
			Globals.messageWindowInstance.details_message_window("BikeReLocked", "misc")

func _on_Bike_mouse_entered():
	Globals.itemObjectHover = true
	Globals.expectedItem = "bikelock"

func _on_Bike_mouse_exited():
	Globals.itemObjectHover = false
	Globals.expectedItem = null

func _on_Bench_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("BenchLook", "park")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if Globals.playerSitting == false:
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
				Globals.messageWindowInstance.details_message_window("BenchSit", "park")
				await Globals.textComplete
				await get_tree().create_timer(1).timeout
				Globals.playerMoney += 100
				Globals.messageWindowInstance.details_message_window("FoundDollar", "park")
				await Globals.textComplete
				Globals.play_sound("res://sounds/dollar.wav")
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
				Globals.playerSitting = true
			else:
				Globals.messageWindowInstance.details_message_window("AlreadySat", "park")

func _on_Trees_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			if Globals.playerSitting == false:
				Globals.messageWindowInstance.details_message_window("NotSitting", "park")
			else:
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
				Globals.messageWindowInstance.details_message_window("Trees", "park")
				await Globals.textComplete
				await get_tree().create_timer(1).timeout
				var copNode = get_node("MainWindow/LocationImage/Actor")
				await Globals.actor_fade_in(copNode)
				await get_tree().create_timer(1).timeout
				Globals.messageWindowInstance.details_message_window("Cop1", "park")
				var answer1 = await Globals.choiceMade
				if answer1 == "0":
					Globals.messageWindowInstance.details_message_window("Cop1-0", "park")
					await Globals.textComplete
					Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory").visible = false
					mapInstance.createMap()
					sceneOver = true
					Globals.parkComplete = true
				if answer1 == "1":
					copNode.texture = load("res://art/actors/officer-mad-16.png")
					Globals.messageWindowInstance.details_message_window("Cop1-1", "park")
					var answer2 = await Globals.choiceMade
					if answer2 == "0":
						Globals.messageWindowInstance.details_message_window("Cop1-1-0", "park")
						await Globals.textComplete
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory").visible = false
						mapInstance.createMap()
						sceneOver = true
						Globals.parkComplete = true
					if answer2 == "1":
						Globals.messageWindowInstance.details_message_window("Cop1-1-1", "park")
						await Globals.textComplete
						copNode.texture = load("res://art/actors/officer-yelling-16.png")
						Globals.messageWindowInstance.details_message_window("Cop1-1-1b", "park")
						var answer3 = await Globals.choiceMade
						if answer3 == "0":
							copNode.texture = load("res://art/actors/officer-mad-16.png")
							Globals.messageWindowInstance.details_message_window("Cop1-1-1-0", "park")
							await Globals.textComplete
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory").visible = false
							mapInstance.createMap()
							sceneOver = true
							Globals.parkComplete = true
						if answer3 == "1":
							Globals.messageWindowInstance.details_message_window("Cop1-1-1-1", "park")
							await Globals.textComplete
							Globals.play_sound("res://sounds/taser.wav")
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
							await get_tree().create_timer(0.2).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
							await get_tree().create_timer(0.1).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
							await get_tree().create_timer(0.1).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
							await get_tree().create_timer(0.3).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
							await get_tree().create_timer(0.1).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
							await get_tree().create_timer(0.2).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
							await get_tree().create_timer(0.2).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
							await get_tree().create_timer(0.1).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
							await get_tree().create_timer(0.3).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
							await get_tree().create_timer(0.2).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
							await get_tree().create_timer(0.1).timeout
							Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
							await get_tree().create_timer(0.2).timeout
							Globals.currentEnding = 7
							await get_tree().create_timer(0.5).timeout
							Globals.do_ending(Globals.currentEnding)
				if answer1 == "2":
					copNode.texture = load("res://art/actors/officer-mad-16.png")
					Globals.messageWindowInstance.details_message_window("Cop1-2", "park")
					await Globals.textComplete
					copNode.texture = load("res://art/actors/officer-yelling-16.png")
					Globals.messageWindowInstance.details_message_window("Cop1-2b", "park")
					await Globals.textComplete
					Globals.play_sound("res://sounds/taser.wav")
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
					await get_tree().create_timer(0.2).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
					await get_tree().create_timer(0.1).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
					await get_tree().create_timer(0.1).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
					await get_tree().create_timer(0.3).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
					await get_tree().create_timer(0.1).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
					await get_tree().create_timer(0.2).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
					await get_tree().create_timer(0.2).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
					await get_tree().create_timer(0.1).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
					await get_tree().create_timer(0.3).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
					await get_tree().create_timer(0.2).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
					await get_tree().create_timer(0.1).timeout
					Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
					await get_tree().create_timer(0.2).timeout
					Globals.currentEnding = 7
					Globals.do_ending(Globals.currentEnding)

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


func _on_BigBlocker_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 or event.button_index == 2 and event.pressed:
			if sceneOver == true:
				mapInstance.createMap()
