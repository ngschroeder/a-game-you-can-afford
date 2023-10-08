extends Node

var settingsInstance = Globals.SettingsInstance.new()

func _ready():
	pass

func createInventory():
	var packNode = load("res://scenes/Inventory.tscn").instantiate()
	var packPosition = Vector2(15,520)
	packNode.set_position(packPosition)
	Globals.getSceneNode().get_node("MainWindow/LocationImage").add_child(packNode)
	var packImgNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/InventoryImage")
	packImgNode.connect("mouse_entered", Callable(self, "_on_Pack_mouse_entered"))
	packImgNode.connect("mouse_exited", Callable(self, "_on_Pack_mouse_exited"))
	packImgNode.connect("gui_input", Callable(self, "_on_Pack_mouse_click"))
	var invWindowNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/Window")
	var invWindowPosition = Vector2(387,-400)
	invWindowNode.set_position(invWindowPosition)
	invWindowNode.visible = false
	var invClickArea = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/Window/BG/ClickArea")
	invClickArea.connect("mouse_entered", Callable(self, "_on_InvWindow_mouse_entered"))
	invClickArea.connect("mouse_exited", Callable(self, "_on_InvWindow_mouse_exited"))
	settingsInstance.createSettings()

func showInventoryWindow():
	var thisNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/Window")
	thisNode.visible = true
	Globals.inventoryOpen = true
	Globals.closeZoomOnClick = true
	var cashIntArray = Globals.playerMoney
	var cashStringArray = str(cashIntArray)
	if cashStringArray.length() < 4:
		var c = 0
		while c < (4 - cashStringArray.length()):
			cashStringArray = "0" + cashStringArray
			print(c)
			c += 1
	print(cashStringArray)
	var i = 0
	while i < cashStringArray.length():
		var numImage = ("res://art/numbers/" + cashStringArray[i] + ".png")
		var numNode = thisNode.get_node("BG/Wallet/" + str(i))
		if cashStringArray[i] == "0":
			numNode.texture = null
		else:
			numNode.texture = load(numImage)
		i += 1
	loadItems()

func loadItems():
	print(Globals.inventory)
	for n in (Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window/BG/ClickArea")).get_children():
		n.visible = false
		n.color = Color(0,0,0,0)
	if (Globals.inventory).size() == null or (Globals.inventory).size() == 0:
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window/BG/Empty").visible = true
	for i in Globals.inventory.size():
		var itemWindow = Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window/BG/ClickArea/Item" + str(i))
		var itemImage = Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window/BG/ClickArea/Item" + str(i) + "/Item" + str(i) + "Image")
		var itemTexture = "res://art/inventory/" + Globals.inventory[i] + ".png"
		itemImage.texture = load(itemTexture)
		itemWindow.visible = true
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Inventory/Window/BG/Empty").visible = false

func _on_Pack_mouse_entered():
	if Globals.getLocationName() == "Apartment-Int" and Globals.apartmentLightOn == false:
		return
	var newPackImage = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/InventoryImage")
	newPackImage.texture = load("res://art/inventory/pack-highlighted.png")

func _on_Pack_mouse_exited():
	var newPackImage = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/InventoryImage")
	newPackImage.texture = load("res://art/inventory/pack.png")

func _on_Pack_mouse_click(event):
	if event is InputEventMouseButton:
		if Globals.getLocationName() == "Apartment-Int" and Globals.apartmentLightOn == false:
			return
		if event.button_index == 1 and event.pressed and Globals.endingInProgress == false:
			showInventoryWindow()

func _on_InvWindow_mouse_entered():
	Globals.closeZoomOnClick = false

func _on_InvWindow_mouse_exited():
	Globals.closeZoomOnClick = true

func _on_Item0Image_mouse_entered():
	get_node("Window/BG/ClickArea/Item0").color = Color(1,1,1,1)
	Globals.closeZoomOnClick = false

func _on_Item0Image_mouse_exited():
	get_node("Window/BG/ClickArea/Item0").color = Color(0,0,0,0)

func _on_Item0Image_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var item = (Globals.inventory[0]).to_lower()
			Globals.itemCursor = item
			Input.set_custom_mouse_cursor(Globals.pointerDict[item])
			get_node("Window").visible = false
			Globals.inventoryOpen = false
			Globals.closeZoomOnClick = false

func _on_Item1Image_mouse_entered():
	get_node("Window/BG/ClickArea/Item1").color = Color(1,1,1,1)
	Globals.closeZoomOnClick = false

func _on_Item1Image_mouse_exited():
	get_node("Window/BG/ClickArea/Item1").color = Color(0,0,0,0)

### This does not always register when selecting an item
func _on_Item1Image_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var item = (Globals.inventory[1]).to_lower()
			Globals.itemCursor = item
			Input.set_custom_mouse_cursor(Globals.pointerDict[item])
			get_node("Window").visible = false
			Globals.inventoryOpen = false
			Globals.closeZoomOnClick = false

func _on_Item2image_mouse_entered():
	get_node("Window/BG/ClickArea/Item2").color = Color(1,1,1,1)
	Globals.closeZoomOnClick = false

func _on_Item2image_mouse_exited():
	get_node("Window/BG/ClickArea/Item2").color = Color(0,0,0,0)


func _on_Item2image_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var item = (Globals.inventory[2]).to_lower()
			Globals.itemCursor = item
			Input.set_custom_mouse_cursor(Globals.pointerDict[item])
			get_node("Window").visible = false
			Globals.inventoryOpen = false
			Globals.closeZoomOnClick = false

func _on_Item3Image_mouse_entered():
	get_node("Window/BG/ClickArea/Item3").color = Color(1,1,1,1)
	Globals.closeZoomOnClick = false

func _on_Item3Image_mouse_exited():
	get_node("Window/BG/ClickArea/Item3").color = Color(0,0,0,0)


func _on_Item4Image_mouse_entered():
	get_node("Window/BG/ClickArea/Item4").color = Color(1,1,1,1)
	Globals.closeZoomOnClick = false

func _on_Item4Image_mouse_exited():
	get_node("Window/BG/ClickArea/Item4").color = Color(0,0,0,0)

func _on_Item5Image_mouse_entered():
	get_node("Window/BG/ClickArea/Item5").color = Color(1,1,1,1)
	Globals.closeZoomOnClick = false

func _on_Item5Image_mouse_exited():
	get_node("Window/BG/ClickArea/Item5").color = Color(0,0,0,0)

func _on_Settings_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if Globals.demoBuild == true:
				var thisNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Inventory/Window")
				thisNode.visible = false
				get_viewport().set_input_as_handled()
				Globals.messageWindowInstance.details_message_window("NoSaveLoad", "misc")
			else:
				var settingsNode = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow")
				settingsNode.visible = true
				settingsInstance.getSaves()
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true

func _on_Settings_mouse_entered():
	Globals.closeZoomOnClick = false
