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

func _on_ExitToys_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				Globals.mouseLocked = false
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Checkout.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_ExitToys_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitToys_mouse_exited():
	if Globals.messageWindowOpen == false:
		if Globals.scanningActive == true:
			Input.set_custom_mouse_cursor(Globals.pointerscanner)
		else:
			Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_ExitToys_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_ExitCheckout_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Toys.tscn")
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

func _on_CoffeePot_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("coffeepot1") and Globals.scannedItems.has("coffeepot2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			elif Globals.scannedItems.has("coffeepot1"):
				Globals.messageWindowInstance.details_message_window("AlreadyScannedMulti", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				if Globals.scannedOneCoffeePot != true:
					Globals.messageWindowInstance.details_message_window("CoffeePot", "scanner")
				else:
					Globals.messageWindowInstance.details_message_window("CoffeePot2", "scanner")
				Globals.scannedOneCoffeePot = true
				Globals.scannedItems.append("coffeepot1")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)


func _on_CoffeePot2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("coffeepot1") and Globals.scannedItems.has("coffeepot2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			elif Globals.scannedItems.has("coffeepot2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScannedMulti", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				if Globals.scannedOneCoffeePot != true:
					Globals.messageWindowInstance.details_message_window("CoffeePot", "scanner")
				else:
					Globals.messageWindowInstance.details_message_window("CoffeePot2", "scanner")
				Globals.scannedOneCoffeePot = true
				Globals.scannedItems.append("coffeepot2")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_BreadMaker_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("breadmaker1") and Globals.scannedItems.has("breadmaker2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			elif Globals.scannedItems.has("breadmaker1"):
				Globals.messageWindowInstance.details_message_window("AlreadyScannedMulti", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				if Globals.scannedOneBreadmaker != true:
					Globals.messageWindowInstance.details_message_window("BreadMaker", "scanner")
				else:
					Globals.messageWindowInstance.details_message_window("BreadMaker2", "scanner")
				Globals.scannedOneBreadmaker = true
				Globals.scannedItems.append("breadmaker1")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_BreadMaker2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("breadmaker1") and Globals.scannedItems.has("breadmaker2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			elif Globals.scannedItems.has("breadmaker2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScannedMulti", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				if Globals.scannedOneBreadmaker != true:
					Globals.messageWindowInstance.details_message_window("BreadMaker", "scanner")
				else:
					Globals.messageWindowInstance.details_message_window("BreadMaker2", "scanner")
				Globals.scannedOneBreadmaker = true
				Globals.scannedItems.append("breadmaker2")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Microwave_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("microwave1") and Globals.scannedItems.has("mocrowave2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			elif Globals.scannedItems.has("microwave1"):
				Globals.messageWindowInstance.details_message_window("AlreadyScannedMulti", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				if Globals.scannedOneMicrowave != true:
					Globals.messageWindowInstance.details_message_window("Microwave", "scanner")
				else:
					Globals.messageWindowInstance.details_message_window("Microwave2", "scanner")
				Globals.scannedOneMicrowave = true
				Globals.scannedItems.append("microwave1")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Microwave2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("microwave1") and Globals.scannedItems.has("mocrowave2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			elif Globals.scannedItems.has("microwave2"):
				Globals.messageWindowInstance.details_message_window("AlreadyScannedMulti", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				if Globals.scannedOneMicrowave != true:
					Globals.messageWindowInstance.details_message_window("Microwave", "scanner")
				else:
					Globals.messageWindowInstance.details_message_window("Microwave2", "scanner")
				Globals.scannedOneMicrowave = true
				Globals.scannedItems.append("microwave2")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_FoodSaver_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("foodsaver"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("FoodSaver", "scanner")
				Globals.scannedItems.append("foodsaver")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Fryer_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("fryer"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Fryer", "scanner")
				Globals.scannedItems.append("fryer")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_Toaster_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("toaster"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("Toaster", "scanner")
				Globals.scannedItems.append("toaster")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)

func _on_CoffeeStuff_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false and Globals.itemCursor == "scanner":
			if Globals.scannedItems.has("coffeestuff"):
				Globals.messageWindowInstance.details_message_window("AlreadyScanned", "scanner")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
			else:
				Globals.messageWindowInstance.details_message_window("CoffeeStuff", "scanner")
				Globals.scannedItems.append("coffeestuff")
				await Globals.textComplete
				Input.set_custom_mouse_cursor(Globals.pointerscanner)
