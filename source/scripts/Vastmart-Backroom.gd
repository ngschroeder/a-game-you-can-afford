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
	# If it's the first time here, describe the place
	if Globals.locationsSeen.has(Globals.currentLocation) == false:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		# Pause for a moment if it's the first time here
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window(str(Globals.currentLocation), "location")
		await Globals.textComplete
		Globals.locationsSeen[Globals.currentLocation] = true
	if Globals.scanningActive == true and Globals.scanningComplete == false and Globals.scannedItems.size() < 10:
		Globals.messageWindowInstance.details_message_window("ScanningIncomplete", "misc")
		await Globals.textComplete
	var actorNode = get_node("MainWindow/LocationImage/Actor")
	if Globals.foundLaurenDay1 == false and Globals.laurenWaiting == false:
		await Globals.actor_fade_in(actorNode)
		if Globals.dressedForWork == true:
			# This is an example of the dialogue handling
			# The dialogue launches a choice and then choosing the choice sends a signal with the response,
			# which then loads a file.
			Globals.messageWindowInstance.details_message_window("Lauren1", "dialogue")
			var answer = await Globals.choiceMade
			Globals.messageWindowInstance.details_message_window(("Lauren1-" + str(answer)), "dialogue")
			await Globals.textComplete
			if answer != "3":
				Globals.messageWindowInstance.item_message_window("Scanner")
				Globals.hasScanner = true
				Globals.inventory.append("Scanner")
				Globals.scanningActive = true
				await Globals.textComplete
			Globals.foundLaurenDay1 = true
			if answer == "3":
				Globals.justQuit = true
				Globals.firedFromVastmart = true
				await Globals.actor_fade_out(actorNode)
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Ext.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)
				return
			await Globals.actor_fade_out(actorNode)
			await get_tree().create_timer(0.5).timeout
			if Globals.faceClean == false:
				await Globals.actor_fade_in(actorNode)
				Globals.messageWindowInstance.details_message_window("Lauren-Dirty", "dialogue")
				await Globals.textComplete
				await Globals.actor_fade_out(actorNode)
				var imageNode = get_node("MainWindow/LocationImage")
				Globals.fade_out(imageNode)
				await get_tree().create_timer(1).timeout
				Globals.fade_in(imageNode)
				Globals.messageWindowInstance.details_message_window("GotCleanAtWork", "misc")
				await Globals.textComplete
				Globals.timesWrittenUp += 1
			Globals.messageWindowInstance.details_message_window("StartScanning", "scanner")
			await Globals.textComplete
		else:
			Globals.messageWindowInstance.details_message_window("Lauren-Clothes", "dialogue")
			await Globals.textComplete
			await Globals.actor_fade_out(actorNode)
			Globals.laurenWaiting = true
			Globals.timesWrittenUp += 1
	print("ScannedItems: ", Globals.scannedItems.size())
	print("TimesWrittenUp: ", Globals.timesWrittenUp)
	if Globals.scanningActive == true and Globals.scanningComplete == false and Globals.scannedItems.size() >= 10:
		await Globals.actor_fade_in(actorNode)
		Globals.messageWindowInstance.details_message_window("Lauren-TaskComplete", "dialogue")
		await Globals.textComplete
		await Globals.actor_fade_out(actorNode)
		Globals.hasScanner = false
		Globals.itemCursor = null
		Globals.inventory.erase("Scanner")
		Globals.scanningActive = false
		Globals.scanningComplete = true
		Globals.VastmartShiftJustEnded = true
	Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false

# This input function executes before the one in Globals and before all the GUI-based ones that come later
func _input(event):
	if event is InputEventMouseButton:
		if Globals.clickDisabled == true:
			get_viewport().set_input_as_handled()

func _on_ExitProduce_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if Globals.demoBuild == true and Globals.foundLaurenDay1 == true:
				Globals.messageWindowInstance.details_message_window("Demo", "misc")
				await Globals.textComplete
			else:
				if event.button_index == 1 and event.pressed:
					var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Produce.tscn")
					if error_code != 0:
						print("ERROR: ", error_code)

func _on_ExitProduce_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitProduce_mouse_exited():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_ExitProduce_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_ExitToys_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if Globals.demoBuild == true and Globals.foundLaurenDay1 == true:
				Globals.messageWindowInstance.details_message_window("Demo", "misc")
				await Globals.textComplete
			else:
				if event.button_index == 1 and event.pressed:
					var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Toys.tscn")
					if error_code != 0:
						print("ERROR: ", error_code)

func _on_ExitToys_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitToys_mouse_exited():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_ExitToys_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false	

func _on_Choice0_mouse_entered():
	var text = "[color=lime][b]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice0").text) + "[/b][/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice0").set_bbcode(text)

func _on_Choice0_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice0").text.replace("[color=lime][b]","").replace("[/b][/color]","")
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
	var text = "[color=lime][b]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice1").text) + "[/b][/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice1").set_bbcode(text)

func _on_Choice1_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice1").text.replace("[color=lime][b]","").replace("[/b][/color]","")
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
	var text = "[color=lime][b]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice2").text) + "[/b][/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice2").set_bbcode(text)

func _on_Choice2_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice2").text.replace("[color=lime][b]","").replace("[/b][/color]","")
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
	var text = "[color=lime][b]" + str(get_node("MainWindow/Overlay/MainText/Choices/Choice3").text) + "[/b][/color]"
	get_node("MainWindow/Overlay/MainText/Choices/Choice3").set_bbcode(text)

func _on_Choice3_mouse_exited():
	var text = get_node("MainWindow/Overlay/MainText/Choices/Choice3").text.replace("[color=lime][b]","").replace("[/b][/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice3").set_bbcode(text)

func _on_Choice3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "3")
			Globals.choiceActive = false
			get_node("MainWindow/Overlay/MainText/Body").visible = true
			get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			get_node("MainWindow/Overlay/MainText/Choices").visible = false

