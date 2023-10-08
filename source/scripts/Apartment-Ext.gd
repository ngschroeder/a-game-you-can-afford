extends Node

var mapInstance = Globals.Map.new()
var inventoryPackInstance = Globals.InventoryInstance.new()

func _ready():
	# Set brightness
	var material = $MainWindow/LocationImage.material as ShaderMaterial
	material.set_shader_parameter("darkness", 1.0)
	Globals.update_size()
	Globals.currentLocation = Globals.getLocationName()
	if Globals.currentLocation != "MainMenu":
		inventoryPackInstance.createInventory()
	if Globals.locationsSeen.has(Globals.currentLocation) == false:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		# Pause for a moment if it's the first time here
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window(str(Globals.currentLocation), "location")
		await Globals.textComplete
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
		Globals.locationsSeen[Globals.currentLocation] = true
	if Globals.bikeLocked == false and Globals.demoBuild != true:
		if Globals.continueInProgress == true:
			Globals.continueInProgress = false
		elif Globals.continueInProgress != true and Globals.bikeArrival != true:
			get_node("MainWindow/LocationImage/Interactives/Bike").visible = false
			Globals.currentEnding = 3
			Globals.messageWindowInstance.details_message_window("BikeStolenApartment", "misc")
	if Globals.pumpsupRobbed == true:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		Globals.clickDisabled = true
		Globals.currentEnding = 5
		Globals.messageWindowInstance.details_message_window("Home-Robber1", "misc")
		await Globals.textComplete
		var robberNode = get_node("MainWindow/LocationImage/Actor")
		await Globals.actor_fade_in(robberNode)
		Globals.messageWindowInstance.details_message_window("Home-Robber2", "misc")
		await Globals.textComplete
		await get_tree().create_timer(1).timeout
		Globals.play_sound("res://sounds/shot.wav")
		Globals.getSceneNode().get_node("MainWindow/Flash").visible = true
		await get_tree().create_timer(0.2).timeout
		Globals.getSceneNode().get_node("MainWindow/Flash").visible = false
		await get_tree().create_timer(1).timeout
		Globals.do_ending(Globals.currentEnding)
	if Globals.hungerMinutes >= 2:
		Globals.hungerCount += 1
		Globals.hungerCheck()

# This is the top-level click event and is used to close all dialogs and other stuff if anything is open, to prevent e.g. being
# able to click on an item and pick it up in the middle of my brilliant exposition on the futility of modern life.
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if (get_node("MainWindow/BikeZoomed").visible == true or Globals.mapOpen == true) and Globals.closeZoomOnClick == true:
				print("I execust in Apartment-Ext click")
				var mapNode = Globals.getSceneNode().get_node_or_null("MainWindow/LocationImage/Map/MapImage")
				if mapNode != null:
					mapNode.visible = false
					Globals.mapOpen = false
				get_node("MainWindow/BikeZoomed").visible = false
				get_node("MainWindow/BikeZoomed/Puzzle").visible = false
				Globals.closeZoomOnClick = false
				get_viewport().set_input_as_handled()

# Stuff to handle the zoomed-in bike view and making it close
func _on_Bike_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.itemCursor == null:
			if Globals.bikePuzzleSolved == false:
				get_node("MainWindow/BikeZoomed").visible = true
				Globals.closeZoomOnClick = true
			else:
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				if Globals.bikeLocked == true:
					Globals.bikeLocked = false
					Globals.inventory.append("BikeLock")
					Globals.messageWindowInstance.details_message_window("BikeUnlocked", "misc")
					await Globals.textComplete
				mapInstance.createMap()
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

func _on_BikeZoomed_mouse_entered():
	Globals.closeZoomOnClick = false
	print("mouse entered")

func _on_BikeZoomed_mouse_exited():
	Globals.closeZoomOnClick = true
	print("mouse exited")

func _on_Lock_mouse_entered():
	Globals.closeZoomOnClick = false

func _on_Puzzle_mouse_entered():
	Globals.closeZoomOnClick = false

# Doorway controls
func _on_ExitField_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 or 2 and event.pressed:
			Globals.bikeArrival = false
			var error_code = get_tree().change_scene_to_file("res://scenes/Apartment-Int.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func _on_ExitField_mouse_entered():
	if Globals.clickDisabled == true:
		return
	if Globals.inventoryOpen == false and Globals.messageWindowOpen == false and Globals.itemCursor == null:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitField_mouse_exited():
	if Globals.clickDisabled == true:
		return
	if Globals.inventoryOpen == false and Globals.messageWindowOpen == false and Globals.itemCursor == null:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_ExitField_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

# Bike Puzzle:
func _on_Lock_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.messageWindowInstance.details_message_window("BikeLock", "object")
		if event.button_index == 2 and !event.pressed:
			get_node("MainWindow/BikeZoomed/Puzzle").visible = true
			setBikecombo(Globals.bikeComboCurrent)

func setBikecombo(combo):
	for i in combo.size():
		var numImage = "res://art/puzzles/bike/" + str(combo[i]) + ".png"
		var numNode = get_node("MainWindow/BikeZoomed/Puzzle/" + str(i))
		numNode.texture = load(numImage)

# Number click controls:

func _on_0_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed:
			updateNumber(0)

func _on_1_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed:
			updateNumber(1)

func _on_2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed:
			updateNumber(2)

func _on_3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed:
			updateNumber(3)

func _on_4_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and !event.pressed:
			updateNumber(4)

# Number cycling and puzzle solve logic
func updateNumber(number):
	Globals.bikeComboCurrent[number] = (Globals.bikeComboCurrent[number] + 1)
	if Globals.bikeComboCurrent[number] == 10:
		Globals.bikeComboCurrent[number] = 0
	var numImage = "res://art/puzzles/bike/" + str(Globals.bikeComboCurrent[number]) + ".png"
	var numNode = get_node("MainWindow/BikeZoomed/Puzzle/" + str(number))
	numNode.texture = load(numImage)
	if Globals.bikeComboCurrent == Globals.bikeComboWinning:
			get_node("MainWindow/BikeZoomed").visible = false
			get_node("MainWindow/BikeZoomed/Puzzle").visible = false
			Globals.messageWindowInstance.details_message_window("BikeUnlocked", "misc")
			Globals.bikePuzzleSolved = true
			Globals.bikeLocked = false
			Globals.inventory.append("BikeLock")

func _on_Bike_mouse_entered():
	Globals.itemObjectHover = true
	Globals.expectedItem = "bikelock"

func _on_Bike_mouse_exited():
	Globals.itemObjectHover = false
	Globals.expectedItem = null

func _on_ApartmentLeft_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.messageWindowInstance.details_message_window("ApartmentBuildingLeft", "misc")

func _on_ApartmentRight_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.messageWindowInstance.details_message_window("ApartmentBuildingRight", "misc")

func _on_ApartmentSky_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.messageWindowInstance.details_message_window("ApartmentSky", "misc")

func _on_ApartmentPath_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.messageWindowInstance.details_message_window("ApartmentExt", "misc")
