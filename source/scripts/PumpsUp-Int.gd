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
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
		Globals.locationsSeen[Globals.currentLocation] = true

func checkEvent():
	if Globals.pumpsupItemsClicked.size() == 3:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		var smallCoupleNode = get_node("MainWindow/LocationImage/SmallCouple")
		var coupleNode = get_node("MainWindow/LocationImage/Glass/Couple")
		await Globals.actor_fade_in(smallCoupleNode)
		Globals.messageWindowInstance.details_message_window("CoupleEnter", "pumpsup")
		await Globals.textComplete
		await Globals.actor_fade_out(smallCoupleNode)
		await Globals.actor_fade_in(coupleNode)
		Globals.messageWindowInstance.details_message_window("Couple-Start", "dialogue")
		await Globals.textComplete
		coupleNode.texture = load("res://art/actors/couple-mad.png")
		await get_tree().create_timer(1).timeout
		Globals.messageWindowInstance.details_message_window("Couple1", "dialogue")
		var answer = await Globals.choiceMade
		Globals.messageWindowInstance.details_message_window(("Couple1-" + str(answer)), "dialogue")
		if answer == "0":
			coupleNode.texture = load("res://art/actors/couple-smile.png")
			await Globals.textComplete
			await Globals.actor_fade_out(coupleNode)
			Globals.messageWindowInstance.details_message_window("Couple-EndGood", "dialogue")
			await Globals.textComplete
			Globals.play_sound("res://sounds/money.wav")
			Globals.playerMoney += 2101
			Globals.soldBeer = true
		elif answer == "1":
			await Globals.textComplete
			coupleNode.texture = load("res://art/actors/couple-laugh.png")
			Globals.messageWindowInstance.details_message_window("Couple1-1b", "dialogue")
			await Globals.textComplete
			await Globals.actor_fade_out(coupleNode)
			Globals.messageWindowInstance.details_message_window("Couple-EndBad", "dialogue")
			Globals.playerMoney += 101
			await Globals.textComplete
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
	if Globals.pumpsupItemsClicked.size() == 5:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
		var smallRobberNode = get_node("MainWindow/LocationImage/SmallRobber")
		var robberNode = get_node("MainWindow/LocationImage/Glass/Robber")
		await Globals.actor_fade_in(smallRobberNode)
		await Globals.messageWindowInstance.details_message_window("RobberEnter", "pumpsup")
		await Globals.textComplete
		await Globals.actor_fade_out(smallRobberNode)
		await Globals.actor_fade_in(robberNode)
		Globals.messageWindowInstance.details_message_window("Robber1", "dialogue")
		var answer = await Globals.choiceMade
		if answer == "0":
			if Globals.playerMoney < 2000:
				Globals.messageWindowInstance.details_message_window("Robber1-nomoney", "dialogue")
				var answer2 = await Globals.choiceMade
				if answer2 == "0":
					# I don't have the money
					if Globals.playerMoney < 500:
						Globals.messageWindowInstance.details_message_window("Robber2-nomoney", "dialogue")
						await Globals.textComplete
						Globals.messageWindowInstance.details_message_window("Robber-Dollar", "dialogue")
						var answer3 = await Globals.choiceMade
						Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
						await get_tree().create_timer(0.5).timeout
						if answer3 == "0":
							Globals.messageWindowInstance.details_message_window("Robber-givedollar", "dialogue")
							await Globals.textComplete
							Globals.playerMoney -= 100
							await Globals.actor_fade_out(robberNode)
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
							Globals.messageWindowInstance.details_message_window("ShiftOver", "pumpsup")
							await Globals.textComplete
							Globals.pumpsupShiftOver = true
							Globals.pumpsupShiftJustEnded = true
							return
						if answer3 == "1":
							Globals.play_sound("res://sounds/guncock.wav")
							await $AudioStreamPlayer.finished
							robberNode.texture = load("res://art/actors/gunman-gun.png")
							Globals.play_sound("res://sounds/gunpulled.wav")
							await get_tree().create_timer(2).timeout
							Globals.messageWindowInstance.details_message_window("Robber-shoot", "dialogue")
							await Globals.textComplete
							await get_tree().create_timer(2).timeout
							Globals.play_sound("res://sounds/shot.wav")
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack1").visible = true
							await get_tree().create_timer(0.5).timeout
							Globals.play_sound("res://sounds/shot.wav")
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack2").visible = true
							await get_tree().create_timer(0.5).timeout
							Globals.play_sound("res://sounds/footsteps.wav")
							await Globals.actor_fade_out(robberNode)
							Globals.messageWindowInstance.details_message_window("Robber-endbad", "dialogue")
							await Globals.textComplete
							Globals.pumpsupJustRobbed = true
							Globals.pumpsupRobbed = true
							Globals.pumpsupShiftOver = true
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
							return
					else:
						Globals.messageWindowInstance.details_message_window("Robber2-money", "dialogue")
						var answer3 = await Globals.choiceMade
						if answer3 == "0":
							Globals.messageWindowInstance.details_message_window("Robber-takecomputer", "dialogue")
							await Globals.textComplete
							Globals.gotComputer = true
							Globals.playerMoney -= 500
							await Globals.actor_fade_out(robberNode)
							Globals.messageWindowInstance.details_message_window("Robber-gotcomputer", "dialogue")
							await Globals.textComplete
							Globals.play_sound("res://sounds/computer.wav")
							Globals.pumpsupShiftOver = true
							Globals.pumpsupShiftJustEnded = true
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
						if answer3 == "1":
							Globals.messageWindowInstance.details_message_window("Robber-Dollar", "dialogue")
							var answer4 = await Globals.choiceMade
							Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
							await get_tree().create_timer(0.5).timeout
							if answer4 == "0":
								Globals.messageWindowInstance.details_message_window("Robber-givedollar", "dialogue")
								await Globals.textComplete
								Globals.playerMoney -= 100
								await Globals.actor_fade_out(robberNode)
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
								Globals.messageWindowInstance.details_message_window("ShiftOver", "pumpsup")
								await Globals.textComplete
								Globals.pumpsupShiftOver = true
								Globals.pumpsupShiftJustEnded = true
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
								return
							if answer4 == "1":
								Globals.play_sound("res://sounds/guncock.wav")
								await $AudioStreamPlayer.finished
								robberNode.texture = load("res://art/actors/gunman-gun.png")
								Globals.play_sound("res://sounds/gunpulled.wav")
								await get_tree().create_timer(2).timeout
								Globals.messageWindowInstance.details_message_window("Robber-shoot", "dialogue")
								await Globals.textComplete
								await get_tree().create_timer(2).timeout
								Globals.play_sound("res://sounds/shot.wav")
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack1").visible = true
								await get_tree().create_timer(0.5).timeout
								Globals.play_sound("res://sounds/shot.wav")
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack2").visible = true
								await get_tree().create_timer(0.5).timeout
								Globals.play_sound("res://sounds/footsteps.wav")
								await Globals.actor_fade_out(robberNode)
								Globals.messageWindowInstance.details_message_window("Robber-endbad", "dialogue")
								await Globals.textComplete
								Globals.pumpsupJustRobbed = true
								Globals.pumpsupRobbed = true
								Globals.pumpsupShiftOver = true
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
								Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
								return
				if answer2 == "1":
					Globals.messageWindowInstance.details_message_window("Robber-Dollar", "dialogue")
					var answer3 = await Globals.choiceMade
					Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
					await get_tree().create_timer(0.5).timeout
					if answer3 == "0":
						Globals.messageWindowInstance.details_message_window("Robber-givedollar", "dialogue")
						await Globals.textComplete
						Globals.playerMoney -= 100
						await Globals.actor_fade_out(robberNode)
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
						Globals.messageWindowInstance.details_message_window("ShiftOver", "pumpsup")
						await Globals.textComplete
						Globals.pumpsupShiftOver = true
						Globals.pumpsupShiftJustEnded = true
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
						return
					if answer3 == "1":
						Globals.play_sound("res://sounds/guncock.wav")
						await $AudioStreamPlayer.finished
						robberNode.texture = load("res://art/actors/gunman-gun.png")
						Globals.play_sound("res://sounds/gunpulled.wav")
						await get_tree().create_timer(2).timeout
						Globals.messageWindowInstance.details_message_window("Robber-shoot", "dialogue")
						await Globals.textComplete
						await get_tree().create_timer(2).timeout
						Globals.play_sound("res://sounds/shot.wav")
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack1").visible = true
						await get_tree().create_timer(0.5).timeout
						Globals.play_sound("res://sounds/shot.wav")
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack2").visible = true
						await get_tree().create_timer(0.5).timeout
						Globals.play_sound("res://sounds/footsteps.wav")
						await Globals.actor_fade_out(robberNode)
						Globals.messageWindowInstance.details_message_window("Robber-endbad", "dialogue")
						await Globals.textComplete
						Globals.pumpsupJustRobbed = true
						Globals.pumpsupRobbed = true
						Globals.pumpsupShiftOver = true
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
						return
			else:
				Globals.messageWindowInstance.details_message_window("Robber1-money", "dialogue")
				var answer2 = await Globals.choiceMade
				if answer2 == "0":
					Globals.messageWindowInstance.details_message_window("Robber-takecomputer", "dialogue")
					await Globals.textComplete
					Globals.gotComputer = true
					Globals.playerMoney -= 2000
					await Globals.actor_fade_out(robberNode)
					Globals.messageWindowInstance.details_message_window("Robber-gotcomputer", "dialogue")
					await Globals.textComplete
					Globals.inventory.append("Laptop")
					Globals.play_sound("res://sounds/computer.wav")
					Globals.pumpsupShiftOver = true
					Globals.pumpsupShiftJustEnded = true
					Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
					Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
				if answer2 == "1":
					Globals.messageWindowInstance.details_message_window("Robber2-money", "dialogue")
					var answer3 = await Globals.choiceMade
					if answer3 == "0":
						Globals.messageWindowInstance.details_message_window("Robber-takecomputer", "dialogue")
						await Globals.textComplete
						Globals.gotComputer = true
						Globals.playerMoney -= 500
						await Globals.actor_fade_out(robberNode)
						Globals.messageWindowInstance.details_message_window("Robber-gotcomputer", "dialogue")
						await Globals.textComplete
						Globals.inventory.append("Laptop")
						Globals.play_sound("res://sounds/computer.wav")
						Globals.pumpsupShiftOver = true
						Globals.pumpsupShiftJustEnded = true
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
					if answer3 == "1":
						Globals.messageWindowInstance.details_message_window("Robber-Dollar", "dialogue")
						var answer4 = await Globals.choiceMade
						Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
						await get_tree().create_timer(0.5).timeout
						if answer4 == "0":
							Globals.messageWindowInstance.details_message_window("Robber-givedollar", "dialogue")
							await Globals.textComplete
							Globals.playerMoney -= 100
							await Globals.actor_fade_out(robberNode)
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
							Globals.messageWindowInstance.details_message_window("ShiftOver", "pumpsup")
							await Globals.textComplete
							Globals.pumpsupShiftOver = true
							Globals.pumpsupShiftJustEnded = true
							return
						if answer4 == "1":
							Globals.play_sound("res://sounds/guncock.wav")
							await $AudioStreamPlayer.finished
							robberNode.texture = load("res://art/actors/gunman-gun.png")
							Globals.play_sound("res://sounds/gunpulled.wav")
							await get_tree().create_timer(2).timeout
							Globals.messageWindowInstance.details_message_window("Robber-shoot", "dialogue")
							await Globals.textComplete
							await get_tree().create_timer(2).timeout
							Globals.play_sound("res://sounds/shot.wav")
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack1").visible = true
							await get_tree().create_timer(0.5).timeout
							Globals.play_sound("res://sounds/shot.wav")
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack2").visible = true
							await get_tree().create_timer(0.5).timeout
							Globals.play_sound("res://sounds/footsteps.wav")
							await Globals.actor_fade_out(robberNode)
							Globals.messageWindowInstance.details_message_window("Robber-endbad", "dialogue")
							await Globals.textComplete
							Globals.pumpsupJustRobbed = true
							Globals.pumpsupRobbed = true
							Globals.pumpsupShiftOver = true
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
							Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
							return
				if answer2 == "2":
					Globals.messageWindowInstance.details_message_window("Robber-Dollar", "dialogue")
					var answer3 = await Globals.choiceMade
					Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
					await get_tree().create_timer(0.5).timeout
					if answer3 == "0":
						Globals.messageWindowInstance.details_message_window("Robber-givedollar", "dialogue")
						await Globals.textComplete
						Globals.playerMoney -= 100
						await Globals.actor_fade_out(robberNode)
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
						Globals.messageWindowInstance.details_message_window("ShiftOver", "pumpsup")
						await Globals.textComplete
						Globals.pumpsupShiftOver = true
						Globals.pumpsupShiftJustEnded = true
						return
					if answer3 == "1":
						Globals.play_sound("res://sounds/guncock.wav")
						await $AudioStreamPlayer.finished
						robberNode.texture = load("res://art/actors/gunman-gun.png")
						Globals.play_sound("res://sounds/gunpulled.wav")
						await get_tree().create_timer(2).timeout
						Globals.messageWindowInstance.details_message_window("Robber-shoot", "dialogue")
						await Globals.textComplete
						await get_tree().create_timer(2).timeout
						Globals.play_sound("res://sounds/shot.wav")
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack1").visible = true
						await get_tree().create_timer(0.5).timeout
						Globals.play_sound("res://sounds/shot.wav")
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack2").visible = true
						await get_tree().create_timer(0.5).timeout
						Globals.play_sound("res://sounds/footsteps.wav")
						await Globals.actor_fade_out(robberNode)
						Globals.messageWindowInstance.details_message_window("Robber-endbad", "dialogue")
						await Globals.textComplete
						Globals.pumpsupJustRobbed = true
						Globals.pumpsupRobbed = true
						Globals.pumpsupShiftOver = true
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
						Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
						return
		if answer == "1":
			Globals.messageWindowInstance.details_message_window("Robber-Dollar", "dialogue")
			var answer2 = await Globals.choiceMade
			Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
			await get_tree().create_timer(0.5).timeout
			if answer2 == "0":
				Globals.messageWindowInstance.details_message_window("Robber-givedollar", "dialogue")
				await Globals.textComplete
				Globals.playerMoney -= 100
				await Globals.actor_fade_out(robberNode)
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
				Globals.messageWindowInstance.details_message_window("ShiftOver", "pumpsup")
				await Globals.textComplete
				Globals.pumpsupShiftOver = true
				Globals.pumpsupShiftJustEnded = true
				return
			if answer2 == "1":
				Globals.play_sound("res://sounds/guncock.wav")
				await $AudioStreamPlayer.finished
				robberNode.texture = load("res://art/actors/gunman-gun.png")
				Globals.play_sound("res://sounds/gunpulled.wav")
				await get_tree().create_timer(2).timeout
				Globals.messageWindowInstance.details_message_window("Robber-shoot", "dialogue")
				await Globals.textComplete
				await get_tree().create_timer(2).timeout
				Globals.play_sound("res://sounds/shot.wav")
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack1").visible = true
				await get_tree().create_timer(0.5).timeout
				Globals.play_sound("res://sounds/shot.wav")
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Glass/Crack2").visible = true
				await get_tree().create_timer(0.5).timeout
				Globals.play_sound("res://sounds/footsteps.wav")
				await Globals.actor_fade_out(robberNode)
				Globals.messageWindowInstance.details_message_window("Robber-endbad", "dialogue")
				await Globals.textComplete
				Globals.pumpsupJustRobbed = true
				Globals.pumpsupRobbed = true
				Globals.pumpsupShiftOver = true
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/SmallBlocker").visible = true
				return


# This input function executes before the one in Globals and before all the GUI-based ones that come later
func _input(event):
	if event is InputEventMouseButton:
		if Globals.clickDisabled == true:
			get_viewport().set_input_as_handled()

###############################################################
#
# EXIT SECTION!
#
##############################################################

func _on_Exit_gui_input(event):
	if event is InputEventMouseButton:
		if Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			if event.button_index == 1 and event.pressed:
				if Globals.pumpsupShiftOver == false:
					Globals.messageWindowInstance.details_message_window("walkout", "pumpsup")
					var answer = await Globals.choiceMade
					Globals.messageWindowInstance.details_message_window(("walkout-" + str(answer)), "pumpsup")
					await Globals.textComplete
					if answer == "0":
						Globals.pumpsupQuit = true
						Globals.pumpsupShiftOver = true
						var error_code = get_tree().change_scene_to_file("res://scenes/PumpsUp-Ext.tscn")
						if error_code != 0:
							print("ERROR: ", error_code)
						return
				else:
					var error_code = get_tree().change_scene_to_file("res://scenes/PumpsUp-Ext.tscn")
					if error_code != 0:
						print("ERROR: ", error_code)
					return


func _on_Exit_mouse_entered():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerexit)
		Globals.mouseLocked = true

func _on_Exit_mouse_exited():
	if Globals.messageWindowOpen == false:
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		Globals.mouseLocked = false

func _on_Exit_tree_exited():
	Input.set_custom_mouse_cursor(Globals.pointerarrow)
	Globals.mouseLocked = false

###############################################################
#
# Object/Clicking section
#
##############################################################

func _on_StoreFloor_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("StoreFloor", "pumpsup")

func _on_Register_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("Register", "pumpsup")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("RegisterHand", "pumpsup")
			if typeof(Globals.pumpsupItemsClicked) == 2:
				Globals.pumpsupItemsClicked = []
			if !Globals.pumpsupItemsClicked.has("register"):
				Globals.pumpsupItemsClicked.append("register")
			await Globals.textComplete
			checkEvent()

func _on_Shelf_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("Shelf", "pumpsup")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("ShelfHand", "pumpsup")
			if typeof(Globals.pumpsupItemsClicked) == 2:
				Globals.pumpsupItemsClicked = []
			if !Globals.pumpsupItemsClicked.has("shelf"):
				Globals.pumpsupItemsClicked.append("shelf")
			await Globals.textComplete
			checkEvent()

func _on_Asprins_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("Asprins", "pumpsup")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("AsprinsHand", "pumpsup")
			if typeof(Globals.pumpsupItemsClicked) == 2:
				Globals.pumpsupItemsClicked = []
			if !Globals.pumpsupItemsClicked.has("asprins"):
				Globals.pumpsupItemsClicked.append("asprins")
			await Globals.textComplete
			checkEvent()

func _on_Safe_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("Safe", "pumpsup")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("SafeHand", "pumpsup")
			if typeof(Globals.pumpsupItemsClicked) == 2:
				Globals.pumpsupItemsClicked = []
			if !Globals.pumpsupItemsClicked.has("safe"):
				Globals.pumpsupItemsClicked.append("safe")
			await Globals.textComplete
			checkEvent()

func _on_Bin_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and Globals.messageWindowOpen == false and event.pressed and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("Bin", "pumpsup")
		if event.button_index == 2 and !event.pressed and Globals.messageWindowOpen == false and Globals.inventoryOpen == false:
			Globals.messageWindowInstance.details_message_window("BinHand", "pumpsup")
			if typeof(Globals.pumpsupItemsClicked) == 2:
				Globals.pumpsupItemsClicked = []
			if !Globals.pumpsupItemsClicked.has("bin"):
				Globals.pumpsupItemsClicked.append("bin")
			await Globals.textComplete
			checkEvent()

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
