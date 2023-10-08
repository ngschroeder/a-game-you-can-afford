extends Node

var inventoryPackInstance = Globals.InventoryInstance.new()

func _ready():
	# Update the scale
	Globals.update_size()
	var material = $MainWindow/LocationImage.material as ShaderMaterial
	material.set_shader_parameter("darkness", 1.0)
	# Set the location for saving
	Globals.currentLocation = Globals.getLocationName()
	# Create the inventory
	if Globals.currentLocation != "MainMenu":
		inventoryPackInstance.createInventory()
	# If it's the first time here, describe the place
	if Globals.locationsSeen.has(Globals.currentLocation) == false:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		# Pause for a moment if it's the first time here
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window(str(Globals.currentLocation), "location")
		Globals.locationsSeen[Globals.currentLocation] = true
		await Globals.textComplete
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
	if Globals.dressedForWork == true:
		get_node("MainWindow/LocationImage/Interactives/WorkClothes").visible = false
		get_node("MainWindow/LocationImage/Interactives/Pajamas").visible = true

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
				var error_code = get_tree().change_scene_to_file("res://scenes/Apartment-Int.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

# This is needed to reset the cursor when the player leaves the room
func _on_ExitField_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false


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


func _on_WorkClothes_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/WorkClothes")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.dressedForWork = true
			if Globals.laurenWaiting == true:
				Globals.laurenWaiting = false
			get_node("MainWindow/LocationImage/Interactives/WorkClothes").visible = false
			Globals.messageWindowInstance.details_message_window(itemNode, "misc")
			await Globals.textComplete
			get_node("MainWindow/LocationImage/Interactives/Pajamas").visible = true

func _on_BathWindow_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/BathWindow")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")

func _on_Shelf_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/Shelf")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")

func _on_Toilet_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/Toilet")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if Globals.toiletUsed == false:
				Globals.messageWindowInstance.details_message_window(itemNode, "misc")
				Globals.toiletUsed = true
				Globals.handsClean = false
			elif Globals.toiletUsed == true:
				Globals.messageWindowInstance.details_message_window("ToiletUsed", "misc")

func _on_BathSink_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/BathSink")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")
		elif event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if Globals.faceClean == false:
				Globals.faceClean = true
				Globals.handsClean = true
				Globals.messageWindowInstance.details_message_window("FaceWash", "misc")
				await Globals.textComplete
				Globals.play_sound("res://sounds/clean.wav")
				if Globals.toiletUsed:
					Globals.messageWindowInstance.details_message_window("SoapGone", "misc")
			elif Globals.faceClean == true and Globals.handsClean == false:
				Globals.handsClean = true
				Globals.messageWindowInstance.details_message_window("PoopWash", "misc")
				await Globals.textComplete
				Globals.messageWindowInstance.details_message_window("SoapGone", "misc")
			else:
				Globals.messageWindowInstance.details_message_window("Sink", "misc")


func _on_Pajamas_gui_input(event):
	if event is InputEventMouseButton:
		var itemNode = get_node("MainWindow/LocationImage/Interactives/Pajamas")
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window(itemNode, "object")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if Globals.endOfDay == false:
				Globals.messageWindowInstance.details_message_window("PajamasNo", "misc")
