extends Node

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
	if Globals.endingScreenLaunch == true:
		get_node("MainWindow/LocationImage").modulate = Color(0,0,0)
		Globals.do_ending(Globals.currentEnding)
		return
	# If it's the first time here, describe the place
	if Globals.locationsSeen.has(Globals.currentLocation) == false:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
		# Pause for a moment if it's the first time here
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window(str(Globals.currentLocation), "location")
		await Globals.textComplete
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
		Globals.locationsSeen[Globals.currentLocation] = true
	# Bike... might need to fix the bike node path
	if Globals.bikeLocked == false:
		if Globals.continueInProgress == true:
			Globals.continueInProgress = false
		elif Globals.continueInProgress != true and Globals.bikeArrival != true:
			get_node("MainWindow/Bike").visible = false
			Globals.messageWindowInstance.details_message_window("BikeStolenApartment", "misc")

# This input function executes before the one in Globals and before all the GUI-based ones that come later
func _input(event):
	if event is InputEventMouseButton:
		if Globals.clickDisabled == true:
			get_viewport().set_input_as_handled()

# Example Item you can pick up
func _on_Item_gui_input(event):
	if event is InputEventMouseButton:
		# Get the node
		var itemNode = get_node("MainWindow/LocationImage/Interactives/ItemNode")
		# If the iteraction is the hand icon (and there are no message windows open)
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			# Hide the item (because we picked it up)
			itemNode.visible = false
			# Show the item details
			Globals.messageWindowInstance.item_message_window(itemNode)
			# And extra condition (if we need it later in the game)
			Globals.someCondition = true
			# Add the item to the inventory
			Globals.inventory.append(itemNode.name)
		# If we only did  a left-click, just show the item details (itenname.txt in the res://text/objects folder)
		if event.button_index == 1 and event.pressed:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")

# When you enter the exit container, change the icon and prevent the hand icon from being used
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
				Globals.bikeArrival = false
				var error_code = get_tree().change_scene_to_file("res://scenes/Z-Template.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

# This is needed to reset the cursor when the player leaves the room
func _on_ExitField_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

# Clickable Events
# Items must have mouse enter/exit functions to set Globals.itemObjectHover to true!

# Trigger item Example with conditions
func _on_Trigger_gui_input(event):
	if event is InputEventMouseButton:
		# If you click with the hand
		if event.button_index == 2 and Globals.messageWindowOpen == false and !event.pressed and Globals.inventoryOpen == false:
			# Check top-level condition
			if Globals.someCondition == false:
				_do_function()
				# Check secondary condition and do something once if this is the first time
				if Globals.someOtherCondition == false:
					_some_other_function_that_only_triggers_once()
					Globals.someOtherCondition = true
					get_viewport().set_input_as_handled()
			else:
				_do_alternate_function()
		# If you left-click, get different results based on a condition
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed:
			if Globals.someCondition == false:
				Globals.messageWindowInstance.details_message_window("LightSwitchDark", "misc")
			else:
				var itemNode = get_node("MainWindow/LocationImage/Interactives/ThisNode")
				Globals.messageWindowInstance.details_message_window(itemNode, "object")

# Very basic item you can look at but not pick up
func _on_Note_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Note")
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				# Do some conditions if you pick it up
				Globals.messageWindowInstance.details_message_window(itemNode, "object")
				Globals.mapLocationsUnlocked["Vastmart"] = true
				Globals.mapLocationsUnlocked["PumpsUp"] = true
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				Globals.messageWindowInstance.details_message_window("NoteBack", "misc")

# Complex interactive with many conditions

# First you must set the object hover and expected interactive items
func _on_Microwave_mouse_entered():
	Globals.itemObjectHover = true
	Globals.expectedItem = "ramen"

# And remove them when the mouse exits
func _on_Microwave_mouse_exited():
	Globals.itemObjectHover = false
	Globals.expectedItem = null


func _on_Microwave_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.apartmentLightOn == true:
			var itemNode = get_node("MainWindow/LocationImage/Interactives/Microwave")
			# Check that you click with the expected item selected (the handler for if it's the wrong item is in Globals _input!)
			if event.button_index == 1 and event.pressed and Globals.itemCursor == "ramen":
				# Remove the item from the itemCursor setting and fix the arrow
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				# Here we have an extra condition (the item needed to be "prepped"
				if Globals.ramenWaterAdded == true:
					# Do all the good stuff (this is a positive outcome)
					Globals.inventory.erase("Ramen")
					Globals.itemCursor = null
					Input.set_custom_mouse_cursor(Globals.pointerarrow)
					itemNode.texture = load("res://art/object/microwave-on.png")
					Globals.messageWindowInstance.details_message_window("RamenInMicrowave", "misc")
					await Globals.textComplete
					await get_tree().create_timer(1).timeout
					itemNode.texture = load("res://art/object/microwave.png")
					# playsound BING!
					Globals.messageWindowInstance.details_message_window("RamenWithWater", "misc")
				else:
					# Do all the bad stuff (this was a negative outcome that ends the game)
					Globals.currentEnding = 1
					itemNode.texture = load("res://art/object/microwave-on.png")
					Globals.messageWindowInstance.details_message_window("RamenInMicrowave", "misc")
					await Globals.textComplete
					await get_tree().create_timer(1).timeout
					get_node("MainWindow/LocationImage/Interactives/MicrowaveFlame").visible = true
					# This text file triggers the apartment burning down ending
					Globals.messageWindowInstance.details_message_window("RamenNoWater", "misc")
					await Globals.textComplete
					await get_tree().create_timer(1).timeout
				get_viewport().set_input_as_handled()
				return
			# These are the normal click event handlers witout an item selected
			if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				Globals.messageWindowInstance.details_message_window(itemNode, "object")
			if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
				Globals.messageWindowInstance.details_message_window(itemNode, "misc")

func _do_function():
	pass

func _do_alternate_function():
	pass

func _some_other_function_that_only_triggers_once():
	pass

func mouseInfo():
	print("            [Mouse Info]")
	print("            MouseLocked: ", Globals.mouseLocked)
	print("      messageWindowOpen: ", Globals.messageWindowOpen)
