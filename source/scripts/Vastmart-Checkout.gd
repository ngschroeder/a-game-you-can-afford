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
	if Globals.scanningComplete == true:
		get_node("MainWindow/LocationImage").texture = load("res://art/locations/vastmart-checkout-empty.png")
	else:
		get_node("MainWindow/LocationImage").texture = load("res://art/locations/vastmart-checkout.png")
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
	else:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
	if Globals.firedNextEntry == true or Globals.timesWrittenUp > 2:
		var actorNode = get_node("MainWindow/LocationImage/Actor")
		await Globals.actor_fade_in(actorNode)
		Globals.messageWindowInstance.details_message_window("Clayton", "dialogue")
		var answer = await Globals.choiceMade
		if answer == "0":
			Globals.messageWindowInstance.details_message_window("Clayton-0", "dialogue")
			await Globals.textComplete
			await Globals.actor_fade_out(actorNode)
			Globals.firedFromVastmart = true
			Globals.justQuit = true
			var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Ext.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)
			return
		elif answer == "1":
			Globals.messageWindowInstance.details_message_window("Clayton-1", "dialogue")
			var answer2 = await Globals.choiceMade
			if answer2 == "0":
				Globals.messageWindowInstance.details_message_window("Clayton-2", "dialogue")
				await Globals.textComplete
				await Globals.actor_fade_out(actorNode)
				Globals.firedFromVastmart = true
				Globals.justQuit = true
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Ext.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)
				return
			elif answer2 == "1":
				Globals.messageWindowInstance.details_message_window("Clayton-Punch", "dialogue")
				Globals.currentEnding = 4
		elif answer == "2":
			Globals.messageWindowInstance.details_message_window("Clayton-Punch", "dialogue")
			Globals.currentEnding = 4

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
func _on_ExitProduce_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitProduce_mouse_exited():
	if Globals.messageWindowOpen == false:
		if Globals.scanningActive == true:
			Input.set_custom_mouse_cursor(Globals.pointerscanner)
		else:
			Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

# Exit to new scene
func _on_ExitProduce_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Produce.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_ExitProduce_tree_exited():
	if Globals.scanningActive == true:
		Input.set_custom_mouse_cursor(Globals.pointerscanner)
	else:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_ExitKitchen_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitKitchen_mouse_exited():
	if Globals.messageWindowOpen == false:
		if Globals.scanningActive == true:
			Input.set_custom_mouse_cursor(Globals.pointerscanner)
		else:
			Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

# Exit to new scene
func _on_ExitKitchen_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Kitchen.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_ExitKitchen_tree_exited():
	if Globals.scanningActive == true:
		Input.set_custom_mouse_cursor(Globals.pointerscanner)
	else:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_ExitStore_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_ExitStore_mouse_exited():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

# Exit to new scene
func _on_ExitStore_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				if Globals.scanningActive == true:
					Globals.messageWindowInstance.details_message_window("walkout", "choices")
					var answer = await Globals.choiceMade
					Globals.messageWindowInstance.details_message_window(("walkout-" + str(answer)), "choices")
					await Globals.textComplete
					if answer == "0":
						print("Player should leave now")
						Globals.hasScanner = false
						Globals.inventory.erase("Scanner")
						Globals.scanningActive = false
						Globals.firedNextEntry = true
						Globals.itemCursor = null
						Input.set_custom_mouse_cursor(Globals.pointerarrow)
						var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Ext.tscn")
						if error_code != 0:
							print("ERROR: ", error_code)
						return
				else:
					var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Ext.tscn")
					if error_code != 0:
						print("ERROR: ", error_code)

func _on_ExitStore_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

func _on_Crowd_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("Crowd", "misc")


func _on_Blocker_gui_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == 2 or event.button_index == 1) and !event.pressed and Globals.foundLaurenDay1 == false:
			Globals.messageWindowInstance.details_message_window("NoLauren", "misc")
		if (event.button_index == 2 or event.button_index == 1) and !event.pressed and Globals.scanningComplete == true:
			Globals.messageWindowInstance.details_message_window("ScanningCompleteCheckout", "misc")

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
