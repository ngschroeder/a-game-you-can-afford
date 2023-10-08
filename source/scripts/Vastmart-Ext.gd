extends Node

var mapInstance = Globals.Map.new()
var inventoryPackInstance = Globals.InventoryInstance.new()

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
	if Globals.bikeLocked == false and Globals.continueInProgress != true:
		if Globals.bikeArrival != true:
			get_node("MainWindow/LocationImage/Interactives/Bike").visible = false
	# If it's the first time here, describe the place
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
	if Globals.justQuit == true:
		Globals.messageWindowInstance.details_message_window("VastmartFired", "misc")
		await Globals.textComplete
		Globals.justQuit = false
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window("ParkUnlocked", "misc")
		await Globals.textComplete
		Globals.mapLocationsUnlocked["Park"] = true
	if Globals.bikeLocked == false:
		if Globals.continueInProgress == true:
			Globals.continueInProgress = false
		elif Globals.continueInProgress != true and Globals.bikeArrival != true:
			get_node("MainWindow/LocationImage/Interactives/Bike").visible = false
			Globals.currentEnding = 3
			Globals.messageWindowInstance.details_message_window("BikeStolenApartment", "misc")
			await Globals.textComplete
			return
	if Globals.VastmartShiftJustEnded == true:
		Globals.messageWindowInstance.details_message_window("ParkUnlocked", "misc")
		await Globals.textComplete
		Globals.VastmartShiftJustEnded = false
		Globals.mapLocationsUnlocked["Park"] = true
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

# Exit functions
func _on_ExitField_mouse_entered():
	if Globals.messageWindowOpen == false and Globals.itemCursor == null:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitField_mouse_exited():
	if Globals.messageWindowOpen == false and Globals.itemCursor == null:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

# Exit to new scene
func _on_ExitField_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				if Globals.demoBuild == true and Globals.foundLaurenDay1 == true:
					Globals.messageWindowInstance.details_message_window("Demo", "misc")
					await Globals.textComplete
				else:
					if Globals.firedFromVastmart == true:
						Globals.messageWindowInstance.details_message_window("VastmartBanned", "misc")
						await Globals.textComplete
					elif Globals.scanningComplete == true:
						Globals.messageWindowInstance.details_message_window("VastmartShiftOver", "misc")
						await Globals.textComplete
					else:
						Globals.bikeArrival = false
						var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Checkout.tscn")
						if error_code != 0:
							print("ERROR: ", error_code)

# This is needed to reset the cursor when the player leaves the room
func _on_ExitField_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_Store_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("VastmartOutside", "misc")
