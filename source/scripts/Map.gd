extends Node

"""
I have not added the map to any locations in the GUI. I instantiate it dynamically.
No idea why. I guess I like trying new things.
"""

var messageWindowInstance = Globals.MessageWindow.new()


func createMap():
	var mapTreeNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node_or_null("Map/MapImage")
	if mapTreeNode != null:
		mapTreeNode.visible = true
		Globals.mapOpen = true
	else:
		var mapNode = load("res://scenes/Map.tscn").instantiate()
		var mapPosition = Vector2(140,65)
		mapNode.set_position(mapPosition)
		Globals.getSceneNode().get_node("MainWindow/LocationImage").add_child(mapNode)
		var mapLocations = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Map/MapImage").get_children()
		for l in mapLocations:
			print(l.name)
			print(Globals.mapLocationsUnlocked[l.name])
			l.visible = Globals.mapLocationsUnlocked[l.name]
		var thisNode = Globals.getSceneNode().get_node("MainWindow/LocationImage").get_node("Map/MapImage")
		thisNode.connect("mouse_entered", Callable(self, "_on_Map_mouse_entered"))
		thisNode.connect("mouse_exited", Callable(self, "_on_Map_mouse_exited"))
		Globals.mapOpen = true

func _on_Home_mouse_entered():
	var newHomeImage = get_node("MapImage/Home")
	newHomeImage.texture = load("res://art/map/home-highlight.png")

func _on_Home_mouse_exited():
	var newHomeImage = get_node("MapImage/Home")
	newHomeImage.texture = load("res://art/map/home.png")

func _on_Home_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if Globals.getLocationName() == "Apartment-Ext":
				messageWindowInstance.details_message_window("AlreadyHere", "misc")
			else:
				Globals.bikeArrival = true
				var error_code = get_tree().change_scene_to_file("res://scenes/Apartment-Ext.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_PumpsUp_mouse_entered():
	var newHomeImage = get_node("MapImage/PumpsUp")
	newHomeImage.texture = load("res://art/map/pumps-up-highlight.png")

func _on_PumpsUp_mouse_exited():
	var newHomeImage = get_node("MapImage/PumpsUp")
	newHomeImage.texture = load("res://art/map/pumps-up.png")

func _on_PumpsUp_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if Globals.demoBuild == true:
				messageWindowInstance.details_message_window("DemoMap", "misc")
			elif Globals.getLocationName() == "PumpsUp-Ext":
				messageWindowInstance.details_message_window("AlreadyHere", "misc")
			else:
				Globals.bikeArrival = true
				var error_code = get_tree().change_scene_to_file("res://scenes/PumpsUp-Ext.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_Vastmart_mouse_entered():
	var newHomeImage = get_node("MapImage/Vastmart")
	newHomeImage.texture = load("res://art/map/vastmart-highlight.png")

func _on_Vastmart_mouse_exited():
	var newHomeImage = get_node("MapImage/Vastmart")
	newHomeImage.texture = load("res://art/map/vastmart.png")

func _on_Vastmart_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if Globals.getLocationName() == "Vastmart-Ext":
				messageWindowInstance.details_message_window("AlreadyHere", "misc")
			else:
				Globals.bikeArrival = true
				var error_code = get_tree().change_scene_to_file("res://scenes/Vastmart-Ext.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_Ultratek_mouse_entered():
	var newHomeImage = get_node("MapImage/Ultratek")
	newHomeImage.texture = load("res://art/map/ultratek-highlight.png")

func _on_Ultratek_mouse_exited():
	var newHomeImage = get_node("MapImage/Ultratek")
	newHomeImage.texture = load("res://art/map/ultratek.png")

func _on_Park_mouse_entered():
	var newHomeImage = get_node("MapImage/Park")
	newHomeImage.texture = load("res://art/map/park-highlight.png")

func _on_Park_mouse_exited():
	var newHomeImage = get_node("MapImage/Park")
	newHomeImage.texture = load("res://art/map/park.png")

func _on_Park_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if Globals.getLocationName() == "Park":
				messageWindowInstance.details_message_window("AlreadyHere", "misc")
			elif Globals.parkComplete == true:
				messageWindowInstance.details_message_window("ParkClosed", "misc")
			else:
				Globals.bikeArrival = true
				var error_code = get_tree().change_scene_to_file("res://scenes/Park.tscn")
				if error_code != 0:
					print("ERROR: ", error_code)

func _on_Map_mouse_entered():
	Globals.closeZoomOnClick = false
	print(Globals.closeZoomOnClick)

func _on_Map_mouse_exited():
	if Globals.messageWindowOpen == false:
		Globals.closeZoomOnClick = true
	print(Globals.closeZoomOnClick)
