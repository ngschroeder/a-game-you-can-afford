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
	# If you've seen the boss, the area is clickable.
	if Globals.foundLaurenDay1 == false or Globals.scanningComplete == true:
		get_node("MainWindow/LocationImage/Interactives/Blocker").visible = true
	else:
		get_node("MainWindow/LocationImage/Interactives/Blocker").visible = false
	# If it's the first time here, describe the place
	if Globals.locationsSeen.has(Globals.currentLocation) == false:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		# Pause for a moment if it's the first time here
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window(str(Globals.currentLocation), "location")
		await Globals.textComplete
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
		Globals.locationsSeen[Globals.currentLocation] = true
	if Globals.scanningActive == true:
		Input.set_custom_mouse_cursor(Globals.pointerscanner)
		Globals.itemCursor = "scanner"
	else:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.itemCursor = null


# This input function executes before the one in Globals and before all the GUI-based ones that come later
func _input(event):
	if event is InputEventMouseButton:
		if Globals.clickDisabled == true:
			get_viewport().set_input_as_handled()

func _on_ExitBackroom_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				Globals.mouseLocked = false
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Backroom.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_ExitBackroom_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitBackroom_mouse_exited():
	if Globals.messageWindowOpen == false:
		if Globals.scanningActive == true:
			Input.set_custom_mouse_cursor(Globals.pointerscanner)
		else:
			Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_ExitBackroom_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_ExitCheckout_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Checkout.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_ExitCheckout_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitCheckout_mouse_exited():
	if Globals.messageWindowOpen == false:
		if Globals.scanningActive == true:
			Input.set_custom_mouse_cursor(Globals.pointerscanner)
		else:
			Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_ExitCheckout_tree_exited():
	if Globals.scanningActive == true:
		Input.set_custom_mouse_cursor(Globals.pointerscanner)
	else:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false
	
func _on_Blocker_gui_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == 2 or event.button_index == 1) and !event.pressed and Globals.foundLaurenDay1 == false:
			Globals.messageWindowInstance.details_message_window("NoLauren", "misc")
		if (event.button_index == 2 or event.button_index == 1) and !event.pressed and Globals.scanningComplete == true:
			Globals.messageWindowInstance.details_message_window("ScanningComplete", "misc")
			
func _on_Beef_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("beef"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Beef", "scanner")
				await Globals.textComplete
				Globals.scannedItems.append("beef")
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Cucumbers_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("cucumbers"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Cucumbers", "scanner")
				Globals.scannedItems.append("cucumbers")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Pork_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("pork"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Pork", "scanner")
				Globals.scannedItems.append("pork")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Lettuce_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("lettuce"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Lettuce", "scanner")
				Globals.scannedItems.append("lettuce")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)


func _on_Oranges_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("oranges"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Oranges", "scanner")
				Globals.scannedItems.append("oranges")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Lady_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedPerson == true:
				Globals.messageWindowInstance.details_message_window("AlreadyScannedPerson", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Woman").visible = true
				await get_tree().create_timer(0.5).timeout
				Globals.messageWindowInstance.details_message_window("ProduceWoman", "dialogue")
				var answer = await Globals.choiceMade
				Globals.messageWindowInstance.details_message_window(("ProduceWoman-" + str(answer)), "dialogue")
				await Globals.textComplete
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Woman").visible = false
				if answer == "1":
					Globals.timesWrittenUp += 1
				Globals.scannedPerson = true
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

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

