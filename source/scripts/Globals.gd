extends Node

# Demo
var demoBuild = false

# Game State
var currentLocation
var continueInProgress = false
var mouseLocked = false
var messageWindowOpen = false
var messageWindowTextComplete
var messageWindowCurrentSegment = 0
var choiceActive = false
var closeZoomOnClick = false
var inventoryOpen = false
var settingsOpen = false
var currentDetailNode
var currentDetailType
var clickDisabled = false
var mapOpen = false
var itemCursor
var itemObjectHover = false
var expectedItem
var currentEnding
var justQuit = false
var scanningActive = false
var firedNextEntry = false
var aiText = ""
var endingSkipped = false
var internetActive = null
var endingInProgress = false
var hungerMinutes = 0
var endingScreenLaunch = false

# This is triggered when you travel with the map, and must be set to false on any exit/enter events to trigger the bike loss ending
var bikeArrival = false
# Some signals for controlling the timing of events
signal textComplete
signal choiceMade
signal aiAnswered


# Location-specific states
var alarmSmackCount = 0		# THIS SHOULD BE 0 FOR NEW GAME
var bikeComboCurrent = [1,1,2,3,0]


# Scripts and instances
const MessageWindow = preload("res://scripts/MessageWindow.gd")
const InventoryInstance = preload("res://scripts/Inventory.gd")
const SettingsInstance = preload("res://scripts/Settings.gd")
const Map = preload("res://scripts/Map.gd")
const UUID = preload("res://scripts/UUID.gd")
var HTTPNode = HTTPRequest.new()
var GPT3HTTPNode = HTTPRequest.new()
var HTTPTestNode = HTTPRequest.new()
var UUIDInstance = UUID.new()
var messageWindowInstance = MessageWindow.new()
var settingsInstance = SettingsInstance.new()
var gameSaveInstance = ConfigFile.new()
var settingsSaveInstance = ConfigFile.new()

# Display and Settings
var player_id = ""
var continueEnabled = false
var currentWidth = DisplayServer.window_get_size().x	# THIS SHOULD BE SAVED (?)
var currentHeight = DisplayServer.window_get_size().y	# THIS SHOULD BE SAVED (?)
var fullscreenEnabled = false				# THIS SHOULD BE SAVED (?)
var currentScale = 1						# THIS SHOULD BE SAVED (?)
var soundEnabled = true						# THIS SHOULD BE SAVED (?)
var telemetryEnabled = true					# THIS SHOULD BE SAVED (?)
var hardcodeEnabled = false					# THIS SHOULD BE SAVED (?)
var startMainMenuOnOptions = false
var defaultFadeOutSpeed = 0.8
var defaultFadeInSpeed = 1.2
var customMouseSize = "default"
var gameStarted = false

# Mouse Info
var pointerarrow
var pointerhand
var pointerexit
var pointerenter
var pointerramen
var pointerbikelock
var pointerscanner
var pointerlaptop
var pointerDict = {} 					# The item pointer icons get stored here (no need to save... maybe?)

# Progress variables - All goes into savegame
var settings_path = "user://settings.cfg"
var autosave_path = "user://autosave.sav"
var save_dir = "user://saves/"
var apartmentLightOn = false			# THIS SHOULD BE FALSE FOR NEW GAME
var bikeLocked = true					# THIS SHOULD BE TRUE FOR NEW GAME
var newGame = false						# THIS SHOULD BE TRUE FOR NEW GAME
var day = 1								# THIS SHOULD BE 1 FOR NEW GAME
var newDay = true						# THIS SHOULD BE TRUE FOR NEW GAME
var bikePuzzleSolved = false			# THIS SHOULD BE FALSE FOR NEW GAME
var ramenWaterAdded = false				# THIS SHOULD BE FALSE FOR NEW GAME
var ramenEaten = false
var toiletUsed = false
var handsClean = true
var faceClean = false
var dressedForWork = false
var foundLaurenDay1 = false
var firedFromVastmart = false
var laurenWaiting = false
var timesWrittenUp = 0
var scanningComplete = false
var VastmartShiftJustEnded = false
var pumpsupRobbed = false
var pumpsupJustRobbed = false
var pumpsupShiftOver = false
var pumpsupShiftJustEnded = false
var pumpsupQuit = false
var hungerCount = 0
var playerSitting = false
var parkComplete = false
var gotComputer = false
var soldBeer = false
var computerPlaced = false
# This is for when you want to change back into pajamas... maybe other stuff later
# Never actually got this far, the game doesn't span multiple days
var endOfDay = false
# var morningWake = false
# var nighttimeWake = 1

# Item State Variables - All goes into savegame
var playerMoney = 325					# THIS SHOULD BE 325 FOR NEW GAME
var hasRamen = false					# THIS SHOULD BE false FOR NEW GAME
var usedRamen = false					# THIS SHOULD BE false FOR NEW GAME
var hasScanner = false
var inventory = []						# THIS SHOULD BE [] FOR NEW GAME
var scannedItems = []
var pumpsupItemsClicked = []
var scannedOneCoffeePot = false
var scannedOneMicrowave = false
var scannedOneBreadmaker = false
var scannedPerson = false
# Location Seen variables - All goes into savegame
var locationsSeen = {}

# Map stuff
var mapLocationsUnlocked = {
	"Home": true,
	"Vastmart": false,
	"PumpsUp": false,
	"Ultratek": false,
	"Park": false
}
# Misc (Puzzle solutions, etc....)
var bikeComboWinning = [2,1,2,3,0]

# Settings stuff
var endingsSeen = []
var creditsWatched = false
var fadeMaterial = ShaderMaterial.new()
var fadeShader = preload("res://art/shaders/fade.tres")

func setNewGameVars():
	Globals.mouseLocked = false
	Globals.messageWindowOpen = false
	Globals.messageWindowCurrentSegment = 0
	Globals.closeZoomOnClick = false
	Globals.inventoryOpen = false
	Globals.currentDetailNode = null
	Globals.currentDetailType = null
	Globals.clickDisabled = false
	Globals.mapOpen = false
	Globals.itemCursor = null
	Globals.itemObjectHover = false
	Globals.expectedItem = null
	Globals.currentEnding = null
	Globals.alarmSmackCount = 0
	Globals.bikeComboCurrent = [6,2,8,3,1]
	Globals.apartmentLightOn = false
	Globals.bikeLocked = true
	Globals.newGame = true
	Globals.day = 1
	Globals.newDay = true
	Globals.bikePuzzleSolved = false
	Globals.ramenWaterAdded = false
	Globals.playerMoney = 325
	Globals.hasRamen = false
	Globals.hasScanner = false
	Globals.usedRamen = false
	Globals.inventory = []
	Globals.scannedItems = []
	Globals.locationsSeen = {}
	Globals.toiletUsed = false
	Globals.handsClean = true
	Globals.faceClean = false
	Globals.dressedForWork = false
	Globals.endOfDay = false
	Globals.bikeArrival = false
	Globals.foundLaurenDay1 = false
	Globals.justQuit = false
	Globals.firedFromVastmart = false
	Globals.laurenWaiting = false
	Globals.timesWrittenUp = 0
	Globals.scanningActive = false
	Globals.firedNextEntry = false
	Globals.scanningComplete = false
	Globals.VastmartShiftJustEnded = false
	Globals.scannedOneCoffeePot = false
	Globals.scannedOneMicrowave = false
	Globals.scannedOneBreadmaker = false
	Globals.scannedPerson = false
	Globals.creditsWatched = false
	Globals.pumpsupItemsClicked = []
	Globals.pumpsupRobbed = false
	Globals.pumpsupJustRobbed = false
	Globals.pumpsupShiftOver = false
	Globals.pumpsupShiftJustEnded = false
	Globals.hungerCount = 0
	Globals.playerSitting = false
	Globals.soldBeer = false
	Globals.pumpsupQuit = false
	Globals.parkComplete = false
	Globals.gotComputer = false
	Globals.computerPlaced = false
	Globals.mapLocationsUnlocked = {
		"Home": true,
		"Vastmart": false,
		"PumpsUp": false,
		"Ultratek": false,
		"Park": false
	}
	
func save_game_data(path):
	Globals.gameSaveInstance = ConfigFile.new()
	Globals.gameSaveInstance.set_value("game_data", "currentLocation", Globals.currentLocation)
	Globals.gameSaveInstance.set_value("game_data", "inventory", Globals.inventory)
	Globals.gameSaveInstance.set_value("game_data", "locationsSeen", Globals.locationsSeen)
	Globals.gameSaveInstance.set_value("game_data", "mapLocationsUnlocked", Globals.mapLocationsUnlocked)
	Globals.gameSaveInstance.set_value("game_data", "bikeComboCurrent", Globals.bikeComboCurrent)
	Globals.gameSaveInstance.set_value("game_data", "apartmentLightOn", Globals.apartmentLightOn)
	Globals.gameSaveInstance.set_value("game_data", "bikeLocked", Globals.bikeLocked)
	Globals.gameSaveInstance.set_value("game_data", "day", Globals.day)
	Globals.gameSaveInstance.set_value("game_data", "bikePuzzleSolved", Globals.bikePuzzleSolved)
	Globals.gameSaveInstance.set_value("game_data", "ramenWaterAdded", Globals.ramenWaterAdded)
	Globals.gameSaveInstance.set_value("game_data", "playerMoney", Globals.playerMoney)
	Globals.gameSaveInstance.set_value("game_data", "hasRamen", Globals.hasRamen)
	Globals.gameSaveInstance.set_value("game_data", "usedRamen", Globals.usedRamen)
	Globals.gameSaveInstance.set_value("game_data", "toiletUsed", Globals.toiletUsed)
	Globals.gameSaveInstance.set_value("game_data", "handsClean", Globals.handsClean)
	Globals.gameSaveInstance.set_value("game_data", "faceClean", Globals.faceClean)
	Globals.gameSaveInstance.set_value("game_data", "dressedForWork", Globals.dressedForWork)
	Globals.gameSaveInstance.set_value("game_data", "endOfDay", Globals.endOfDay)
	Globals.gameSaveInstance.set_value("game_data", "bikeArrival", Globals.bikeArrival)
	Globals.gameSaveInstance.set_value("game_data", "foundLaurenDay1", Globals.foundLaurenDay1)
	Globals.gameSaveInstance.set_value("game_data", "hasScanner", Globals.hasScanner)
	Globals.gameSaveInstance.set_value("game_data", "justQuit", Globals.justQuit)
	Globals.gameSaveInstance.set_value("game_data", "firedFromVastmart", Globals.firedFromVastmart)
	Globals.gameSaveInstance.set_value("game_data", "laurenWaiting", Globals.laurenWaiting)
	Globals.gameSaveInstance.set_value("game_data", "timesWrittenUp", Globals.timesWrittenUp)
	Globals.gameSaveInstance.set_value("game_data", "scanningActive", Globals.scanningActive)
	Globals.gameSaveInstance.set_value("game_data", "firedNextEntry", Globals.firedNextEntry)
	Globals.gameSaveInstance.set_value("game_data", "scannedItems", Globals.scannedItems)
	Globals.gameSaveInstance.set_value("game_data", "scanningComplete", Globals.scanningComplete)
	Globals.gameSaveInstance.set_value("game_data", "VastmartShiftJustEnded", Globals.VastmartShiftJustEnded)
	Globals.gameSaveInstance.set_value("game_data", "scannedOneCoffeePot", Globals.scannedOneCoffeePot)
	Globals.gameSaveInstance.set_value("game_data", "scannedOneMicrowave", Globals.scannedOneMicrowave)
	Globals.gameSaveInstance.set_value("game_data", "scannedOneBreadmaker", Globals.scannedOneBreadmaker)
	Globals.gameSaveInstance.set_value("game_data", "scannedPerson", Globals.scannedPerson)
	Globals.gameSaveInstance.set_value("game_data", "creditsWatched", Globals.creditsWatched)
	Globals.gameSaveInstance.set_value("game_data", "pumpsupItemsClicked", Globals.pumpsupItemsClicked)
	Globals.gameSaveInstance.set_value("game_data", "pumpsupRobbed", Globals.pumpsupRobbed)
	Globals.gameSaveInstance.set_value("game_data", "pumpsupJustRobbed", Globals.pumpsupJustRobbed)
	Globals.gameSaveInstance.set_value("game_data", "pumpsupShiftOver", Globals.pumpsupShiftOver)
	Globals.gameSaveInstance.set_value("game_data", "pumpsupShiftJustEnded", Globals.pumpsupShiftJustEnded)
	Globals.gameSaveInstance.set_value("game_data", "hungerCount", Globals.hungerCount)
	Globals.gameSaveInstance.set_value("game_data", "playerSitting", Globals.playerSitting)
	Globals.gameSaveInstance.set_value("game_data", "soldBeer", Globals.soldBeer)
	Globals.gameSaveInstance.set_value("game_data", "pumpsupQuit", Globals.pumpsupQuit)
	Globals.gameSaveInstance.set_value("game_data", "parkComplete", Globals.parkComplete)
	Globals.gameSaveInstance.set_value("game_data", "gotComputer", Globals.gotComputer)
	Globals.gameSaveInstance.set_value("game_data", "computerPlaced", Globals.computerPlaced)
	Globals.gameSaveInstance.save(path)

func load_game_data(path):
	Globals.gameSaveInstance.load(path)
	Globals.currentLocation = Globals.gameSaveInstance.get_value("game_data", "currentLocation")
	Globals.inventory = Globals.gameSaveInstance.get_value("game_data", "inventory")
	Globals.locationsSeen = Globals.gameSaveInstance.get_value("game_data", "locationsSeen")
	Globals.mapLocationsUnlocked = Globals.gameSaveInstance.get_value("game_data", "mapLocationsUnlocked")
	Globals.bikeComboCurrent = Globals.gameSaveInstance.get_value("game_data", "bikeComboCurrent")
	Globals.apartmentLightOn = Globals.gameSaveInstance.get_value("game_data", "apartmentLightOn")
	Globals.bikeLocked = Globals.gameSaveInstance.get_value("game_data", "bikeLocked")	
	Globals.day = Globals.gameSaveInstance.get_value("game_data", "day")
	Globals.bikePuzzleSolved = Globals.gameSaveInstance.get_value("game_data", "bikePuzzleSolved")
	Globals.ramenWaterAdded = Globals.gameSaveInstance.get_value("game_data", "ramenWaterAdded")
	Globals.playerMoney = Globals.gameSaveInstance.get_value("game_data", "playerMoney")
	Globals.hasRamen = Globals.gameSaveInstance.get_value("game_data", "hasRamen")
	Globals.usedRamen = Globals.gameSaveInstance.get_value("game_data", "usedRamen")
	Globals.toiletUsed = Globals.gameSaveInstance.get_value("game_data", "toiletUsed")
	Globals.handsClean = Globals.gameSaveInstance.get_value("game_data", "handsClean")
	Globals.faceClean = Globals.gameSaveInstance.get_value("game_data", "faceClean")
	Globals.dressedForWork = Globals.gameSaveInstance.get_value("game_data", "dressedForWork")
	Globals.endOfDay = Globals.gameSaveInstance.get_value("game_data", "endOfDay")
	Globals.bikeArrival = Globals.gameSaveInstance.get_value("game_data", "bikeArrival")
	Globals.foundLaurenDay1 = Globals.gameSaveInstance.get_value("game_data", "foundLaurenDay1")
	Globals.hasScanner = Globals.gameSaveInstance.get_value("game_data", "hasScanner")
	Globals.justQuit = Globals.gameSaveInstance.get_value("game_data", "justQuit")
	Globals.firedFromVastmart = Globals.gameSaveInstance.get_value("game_data", "firedFromVastmart")
	Globals.laurenWaiting = Globals.gameSaveInstance.get_value("game_data", "laurenWaiting")
	Globals.timesWrittenUp = Globals.gameSaveInstance.get_value("game_data", "timesWrittenUp")
	Globals.scanningActive = Globals.gameSaveInstance.get_value("game_data", "scanningActive")
	Globals.firedNextEntry = Globals.gameSaveInstance.get_value("game_data", "firedNextEntry")
	Globals.scannedItems = Globals.gameSaveInstance.get_value("game_data", "scannedItems")
	Globals.scanningComplete = Globals.gameSaveInstance.get_value("game_data", "scanningComplete")
	Globals.VastmartShiftJustEnded = Globals.gameSaveInstance.get_value("game_data", "VastmartShiftJustEnded")
	Globals.scannedOneCoffeePot = Globals.gameSaveInstance.get_value("game_data", "scannedOneCoffeePot")
	Globals.scannedOneMicrowave = Globals.gameSaveInstance.get_value("game_data", "scannedOneMicrowave")
	Globals.scannedOneBreadmaker = Globals.gameSaveInstance.get_value("game_data", "scannedOneBreadmaker")
	Globals.scannedPerson = Globals.gameSaveInstance.get_value("game_data", "scannedPerson")
	Globals.creditsWatched = Globals.gameSaveInstance.get_value("game_data", "creditsWatched")
	Globals.pumpsupItemsClicked = Globals.gameSaveInstance.get_value("game_data", "pumpsupItemsClicked")
	Globals.pumpsupRobbed = Globals.gameSaveInstance.get_value("game_data", "pumpsupRobbed")
	Globals.pumpsupJustRobbed = Globals.gameSaveInstance.get_value("game_data", "pumpsupJustRobbed")
	Globals.pumpsupShiftOver = Globals.gameSaveInstance.get_value("game_data", "pumpsupShiftOver")
	Globals.pumpsupShiftJustEnded = Globals.gameSaveInstance.get_value("game_data", "pumpsupShiftJustEnded")
	Globals.hungerCount = Globals.gameSaveInstance.get_value("game_data", "hungerCount")
	Globals.playerSitting = Globals.gameSaveInstance.get_value("game_data", "playerSitting")
	Globals.soldBeer = Globals.gameSaveInstance.get_value("game_data", "soldBeer")
	Globals.pumpsupQuit = Globals.gameSaveInstance.get_value("game_data", "pumpsupQuit")
	Globals.parkComplete = Globals.gameSaveInstance.get_value("game_data", "parkComplete")
	Globals.gotComputer = Globals.gameSaveInstance.get_value("game_data", "gotComputer")
	Globals.computerPlaced = Globals.gameSaveInstance.get_value("game_data", "computerPlaced")

func _init():
	messageWindowOpen = false

func _ready():
	fadeMaterial.shader = fadeShader
	fadeMaterial.set_shader_parameter("darkness", 1)
	if !DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
	var saveCount = list_files_in_directory(save_dir)
	
	if saveCount.size() != 0:
		Globals.continueEnabled = true
		Globals.loadLastSave()
	Input.set_custom_mouse_cursor(pointerarrow,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	var sceneNode = getSceneNode()
	currentScale = sceneNode.get_node("MainWindow").scale.x
	messageWindowInstance = MessageWindow.new()
	# Create the instance for telemetry
	HTTPNode.name = "HTTPNode"
	GPT3HTTPNode.name = "GPT3HTTPNode"
	HTTPTestNode.name = "HTTPTestNode"
	add_child(HTTPNode)
	add_child(GPT3HTTPNode)
	add_child(HTTPTestNode)
	$HTTPNode.connect("request_completed", Callable(self, "_http_post_data_request_completed"))
	$GPT3HTTPNode.connect("request_completed", Callable(self, "_http_post_gpt3_data_request_completed"))
	$HTTPTestNode.connect("request_completed", Callable(self, "_http_test_request_completed"))
	randomize()
	test_internet()

func _input(event):	
	var location = getLocationName()
	var sceneNode = get_tree().get_root().get_child(1)
	if event is InputEventMouseButton and location != "MainMenu" and location != "Credits":
		if mouseLocked == false and messageWindowOpen == false and closeZoomOnClick == false and clickDisabled == false and itemCursor == null and scanningActive == false:
			if event.button_index == 2 and event.pressed:
				Input.set_custom_mouse_cursor(pointerhand)
			if event.button_index == 2 and !event.pressed:
				Input.set_custom_mouse_cursor(pointerarrow)
		if event.button_index == 1 and event.pressed:
			if messageWindowOpen == false and closeZoomOnClick == false:
				# Disabling this, used to collect click data (mouse position) as telemetry POC
				# post_data("click_info", str(get_viewport().get_mouse_position()))
				pass
			if location == "Credits":
				pass
			elif Globals.messageWindowOpen == true and Globals.messageWindowTextComplete == true and Globals.choiceActive == false:
				sceneNode.get_node("MainWindow/Overlay/MainText").visible = false
				sceneNode.get_node("MainWindow/Overlay/ItemText").visible = false
				Globals.messageWindowOpen = false
				emit_signal("textComplete")
				get_viewport().set_input_as_handled()
			elif Globals.inventoryOpen == true and Globals.closeZoomOnClick == true:
				sceneNode.get_node("MainWindow/LocationImage/Inventory/Window").visible = false
				Globals.inventoryOpen = false
				emit_signal("textComplete")
				Globals.closeZoomOnClick = false
				get_viewport().set_input_as_handled()
			elif Globals.messageWindowOpen == true and Globals.messageWindowTextComplete == false:
				messageWindowInstance.details_message_window(Globals.currentDetailNode, Globals.currentDetailType)
				get_viewport().set_input_as_handled()
			elif itemCursor != null and itemObjectHover == false and scanningActive == false:
				messageWindowInstance.details_message_window("WrongClick", "misc")
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				get_viewport().set_input_as_handled()
			elif itemObjectHover == true and itemCursor != null and itemCursor != expectedItem:
				messageWindowInstance.details_message_window("WrongClick", "misc")
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				get_viewport().set_input_as_handled()
		elif event.button_index == 2 and event.pressed:
			if itemCursor != null:
				get_viewport().set_input_as_handled()
				"""
				messageWindowInstance.details_message_window("WrongClick", "misc")
				Globals.itemCursor = null
				Input.set_custom_mouse_cursor(Globals.pointerarrow)
				get_viewport().set_input_as_handled()
				"""

	if event is InputEventKey:
		if OS.get_keycode_string(event.keycode) == "Space" and !event.pressed:
			var settingsNode = Globals.getSceneNode().get_node("MainWindow/LocationImage/Settings/SaveWindow")
			if settingsNode.visible != true:
				var commandNode = sceneNode.get_node("MainWindow/Overlay/Command")
				commandNode.visible = true
				commandNode.get_child(0).grab_focus()
		if OS.get_keycode_string(event.keycode) == "A" and event.pressed:
			pass
			# Tested HTTP post stuff here

# Game Utilities

func choice_parser(choiceArray):
	getSceneNode().get_node("MainWindow/Overlay/MainText/Body").visible = false
	getSceneNode().get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = true
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices").visible = true
	getSceneNode().get_node("MainWindow/Overlay/MainText").visible = true
	var choiceNodes = getSceneNode().get_node("MainWindow/Overlay/MainText/Choices").get_children()
	for i in choiceNodes:
		i.visible = false
	var n = 0
	while n < (choiceArray.size() - 1):
		choiceNodes[n].set_bbcode(choiceArray[n])
		choiceNodes[n].visible = true
		n += 1

func getLocationName():
	var locationName = get_tree().get_root().get_child(1).name
	return locationName

func getSceneNode():
	var sceneNode = get_tree().get_root().get_child(1)
	return sceneNode
	
func getMessageWindow():
	var messageWindowNode = get_tree().get_root().get_child(1).get_node("Overlay/MainText")
	return messageWindowNode

# Display Settings Stuff

func getCurrentWidth():
	currentWidth = get_window().get_size().x
	return currentWidth

func getCurrentHeight():
	currentHeight = get_window().get_size().y
	return currentHeight

func resize_game(width: int, height: int, scale: float, newFullscreen):
	var sceneNode = getSceneNode()

	if newFullscreen == "true":
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		fullscreenEnabled = true
		get_tree().root.content_scale_size = Vector2(1280,720)
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP 
	else:
		get_window().mode = Window.MODE_WINDOWED
		fullscreenEnabled = false
		get_tree().root.content_scale_size = Vector2(1280,720)
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP 
		
	get_window().set_size(Vector2(width, height))
	sceneNode.get_node("MainWindow").scale.x = float(scale)
	sceneNode.get_node("MainWindow").scale.y = float(scale)
	set_mousepointer()
	currentWidth = getCurrentWidth()
	currentScale = scale

func update_size():
	var sceneNode = getSceneNode()
	sceneNode.get_node("MainWindow").scale.x = float(currentScale)
	sceneNode.get_node("MainWindow").scale.y = float(currentScale)

func set_mousepointer():
	if get_window().get_size().x <= 1280:
		pointerarrow = load("res://art/pointers/arrow-small.png")
		pointerhand = load("res://art/pointers/hand-small.png")
		pointerexit = load("res://art/pointers/exit-small.png")
		pointerenter = load("res://art/pointers/door-small.png")
		pointerramen = load("res://art/pointers/items/ramen-small.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-small.png")
		pointerscanner = load("res://art/pointers/items/scanner-small.png")
		pointerlaptop = load("res://art/pointers/items/laptop-small.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	elif get_window().get_size().x > 1280 and get_window().get_size().x <= 1920:
		pointerarrow = load("res://art/pointers/arrow-med.png")
		pointerhand = load("res://art/pointers/hand-med.png")
		pointerexit = load("res://art/pointers/exit-med.png")
		pointerenter = load("res://art/pointers/door-med.png")
		pointerramen = load("res://art/pointers/items/ramen-med.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-med.png")
		pointerscanner = load("res://art/pointers/items/scanner-med.png")
		pointerlaptop = load("res://art/pointers/items/laptop-med.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	elif get_window().get_size().x > 1920 and get_window().get_size().x <= 2560:
		pointerarrow = load("res://art/pointers/arrow-large.png")
		pointerhand = load("res://art/pointers/hand-large.png")
		pointerexit = load("res://art/pointers/exit-large.png")
		pointerenter = load("res://art/pointers/door-large.png")
		pointerramen = load("res://art/pointers/items/ramen-large.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-large.png")
		pointerscanner = load("res://art/pointers/items/scanner-large.png")
		pointerlaptop = load("res://art/pointers/items/laptop-large.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	elif get_window().get_size().x > 2560:
		pointerarrow = load("res://art/pointers/arrow-jumbo.png")
		pointerhand = load("res://art/pointers/hand-jumbo.png")
		pointerexit = load("res://art/pointers/exit-jumbo.png")
		pointerenter = load("res://art/pointers/door-jumbo.png")
		pointerramen = load("res://art/pointers/items/ramen-jumbo.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-jumbo.png")
		pointerscanner = load("res://art/pointers/items/scanner-jumbo.png")
		pointerlaptop = load("res://art/pointers/items/laptop-jumbo.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)	
	pointerDict["ramen"] = pointerramen
	pointerDict["bikelock"] = pointerbikelock
	pointerDict["scanner"] = pointerscanner
	pointerDict["laptop"] = pointerlaptop

func set_mouse_manual(size):
	if size == "small":
		pointerarrow = load("res://art/pointers/arrow-small.png")
		pointerhand = load("res://art/pointers/hand-small.png")
		pointerexit = load("res://art/pointers/exit-small.png")
		pointerenter = load("res://art/pointers/door-small.png")
		pointerramen = load("res://art/pointers/items/ramen-small.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-small.png")
		pointerscanner = load("res://art/pointers/items/scanner-small.png")
		pointerlaptop = load("res://art/pointers/items/laptop-small.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	elif size == "medium":
		pointerarrow = load("res://art/pointers/arrow-med.png")
		pointerhand = load("res://art/pointers/hand-med.png")
		pointerexit = load("res://art/pointers/exit-med.png")
		pointerenter = load("res://art/pointers/door-med.png")
		pointerramen = load("res://art/pointers/items/ramen-med.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-med.png")
		pointerscanner = load("res://art/pointers/items/scanner-med.png")
		pointerlaptop = load("res://art/pointers/items/laptop-med.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	elif size == "large":
		pointerarrow = load("res://art/pointers/arrow-large.png")
		pointerhand = load("res://art/pointers/hand-large.png")
		pointerexit = load("res://art/pointers/exit-large.png")
		pointerenter = load("res://art/pointers/door-large.png")
		pointerramen = load("res://art/pointers/items/ramen-large.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-large.png")
		pointerscanner = load("res://art/pointers/items/scanner-large.png")
		pointerlaptop = load("res://art/pointers/items/laptop-large.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	elif size == "jumbo":
		pointerarrow = load("res://art/pointers/arrow-jumbo.png")
		pointerhand = load("res://art/pointers/hand-jumbo.png")
		pointerexit = load("res://art/pointers/exit-jumbo.png")
		pointerenter = load("res://art/pointers/door-jumbo.png")
		pointerramen = load("res://art/pointers/items/ramen-jumbo.png")
		pointerbikelock = load("res://art/pointers/items/bikelock-jumbo.png")
		pointerscanner = load("res://art/pointers/items/scanner-jumbo.png")
		pointerlaptop = load("res://art/pointers/items/laptop-jumbo.png")
		Input.set_custom_mouse_cursor(pointerarrow)
		Input.set_custom_mouse_cursor(pointerarrow, Input.CURSOR_IBEAM)
	pointerDict["ramen"] = pointerramen
	pointerDict["bikelock"] = pointerbikelock
	pointerDict["scanner"] = pointerscanner
	pointerDict["laptop"] = pointerlaptop

func cycle_mouse():
	print("I clicked")
	print(Globals.customMouseSize)
	if Globals.customMouseSize == "default":
		Globals.customMouseSize = "small"
		Globals.getSceneNode().get_node("MainWindow/OptionImage/Mouse/MouseSelection").texture = load("res://art/menu/small.png")
		set_mouse_manual(Globals.customMouseSize)
		Globals.settingsSaveInstance.set_value("settings", "customMouseSize", Globals.customMouseSize)
		Globals.settingsSaveInstance.save(settings_path)
		return
	if Globals.customMouseSize == "small":
		Globals.customMouseSize = "medium"
		Globals.getSceneNode().get_node("MainWindow/OptionImage/Mouse/MouseSelection").texture = load("res://art/menu/medium.png")
		set_mouse_manual(Globals.customMouseSize)
		Globals.settingsSaveInstance.set_value("settings", "customMouseSize", Globals.customMouseSize)
		Globals.settingsSaveInstance.save(settings_path)
		return
	if Globals.customMouseSize == "medium":
		Globals.customMouseSize = "large"
		Globals.getSceneNode().get_node("MainWindow/OptionImage/Mouse/MouseSelection").texture = load("res://art/menu/large.png")
		set_mouse_manual(Globals.customMouseSize)
		Globals.settingsSaveInstance.set_value("settings", "customMouseSize", Globals.customMouseSize)
		Globals.settingsSaveInstance.save(settings_path)
		return
	if Globals.customMouseSize == "large":
		Globals.customMouseSize = "jumbo"
		Globals.getSceneNode().get_node("MainWindow/OptionImage/Mouse/MouseSelection").texture = load("res://art/menu/jumbo.png")
		set_mouse_manual(Globals.customMouseSize)
		Globals.settingsSaveInstance.set_value("settings", "customMouseSize", Globals.customMouseSize)
		Globals.settingsSaveInstance.save(settings_path)
		return
	if Globals.customMouseSize == "jumbo":
		Globals.customMouseSize = "default"
		Globals.getSceneNode().get_node("MainWindow/OptionImage/Mouse/MouseSelection").texture = load("res://art/menu/default.png")
		set_mousepointer()
		Globals.settingsSaveInstance.set_value("settings", "customMouseSize", Globals.customMouseSize)
		Globals.settingsSaveInstance.save(settings_path)
		return
# File utility

func list_files_in_directory(path):
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func load_file(filename):
	var result = []
	var f
	if FileAccess.file_exists(filename):
		f = FileAccess.open(filename, FileAccess.READ)
		var index = 0
		while not f.eof_reached():
			var line = f.get_line()
			result.insert(index, line)
			index += 1
		f.close()
		return result
	else:
		var error = ["Error, file not found.","","------------------------------------------------"]
		return error

func search_ending_files(ending, files):
	var regex = RegEx.new()
	var regexString = "^" + str(ending) +"-[^\\\\]*\\.png.import$"
	var result = []
	regex.compile(regexString)
	var i = 0
	while i < files.size():
		var matchText = regex.search(files[i])
		if matchText != null:
			result.append(files[i])
		i += 1
	return result


# Sound stuff

func do_smack():
	var tween = getSceneNode().get_node("MainWindow/LocationImage").create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(getSceneNode().get_node("MainWindow/LocationImage"), "position", Vector2(20, 60), 0.05)
	tween.tween_property(getSceneNode().get_node("MainWindow/LocationImage"), "position", Vector2(-20, 20), 0.08)
	tween.tween_property(getSceneNode().get_node("MainWindow/LocationImage"), "position", Vector2(-20, 60), 0.08)
	tween.tween_property(getSceneNode().get_node("MainWindow/LocationImage"), "position", Vector2(5, 35), 0.08)
	tween.tween_property(getSceneNode().get_node("MainWindow/LocationImage"), "position", Vector2(0, 40), 0.05)

func play_sound(file):
	var audioNode = getSceneNode().get_node("AudioStreamPlayer")
	var sound : AudioStream = load(file)
	audioNode.set_stream(sound)
	if Globals.soundEnabled == true:
		audioNode.play()

func play_smack_sound():
	var audioNode = getSceneNode().get_node("AudioStreamPlayer")
	var sound : AudioStream = load("res://sounds/bash.wav")
	audioNode.set_stream(sound)
	if Globals.soundEnabled == true:
		audioNode.play()

func play_alarm():
	var audioNode = getSceneNode().get_node("AudioStreamPlayerAlarm")
	var sound : AudioStream = load("res://sounds/alarm.wav")
	audioNode.set_stream(sound)
	if Globals.soundEnabled == true:
		audioNode.play()

func stop_alarm():
	var audioNode = getSceneNode().get_node("AudioStreamPlayerAlarm")
	if Globals.soundEnabled == true:
		audioNode.stop()

func play_gameover_sound():
	var audioNode = getSceneNode().get_node("AudioStreamPlayer")
	var sound : AudioStream = load("res://sounds/gameover.wav")
	audioNode.set_stream(sound)
	if Globals.soundEnabled == true:
		audioNode.play()

func game_over_fadeout():
	play_gameover_sound()
	var thisImage = getSceneNode().get_node("MainWindow/LocationImage")
	var currentValue = thisImage.material.get_shader_parameter("desaturation_strength")
	while currentValue > 0.05:
		currentValue = currentValue * 0.90
		thisImage.material.set_shader_parameter("desaturation_strength",currentValue)
		await get_tree().create_timer(0.3).timeout
	fade_out(thisImage)

# Hunger check

func hungerCheck():
	if Globals.usedRamen == false:
		Globals.hungerMinutes = 0
		if Globals.hungerCount > 0:
			await get_tree().create_timer(1).timeout
			Globals.messageWindowInstance.details_message_window(str(Globals.hungerCount), "hunger")
			await Globals.textComplete
			if Globals.hungerCount == 4:
				Globals.currentEnding = 6
				Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = true
				Globals.do_ending(Globals.currentEnding)

# Ending Squencer

func do_ending(endingNumber):
	Globals.endingInProgress = true
	var imageNode = getSceneNode().get_node("MainWindow/LocationImage")
	getSceneNode().get_node("MainWindow/LocationImage/Inventory/InventoryImage").visible = false
	var childNodes = imageNode.get_node("Interactives").get_children()
	var actorNode = getSceneNode().get_node("MainWindow/LocationImage/Actor")
	# Skip some stuff if the ending is starting from the Endings menu
	if Globals.endingScreenLaunch != true:
		play_gameover_sound()
		var currentValue = imageNode.material.get_shader_parameter("desaturation_strength")
		while currentValue > 0.05:
			currentValue = currentValue * 0.93
			imageNode.material.set_shader_parameter("desaturation_strength",currentValue)
			await get_tree().create_timer(0.2).timeout
		await fade_out(imageNode)
		imageNode.material.set_shader_parameter("desaturation_strength",1)
	if actorNode != null:
		actorNode.visible = false
	for i in childNodes.size():
		childNodes[i].visible = false
	clickDisabled = false
	if currentLocation == "Apartment-Int":
		getSceneNode()._set_light_room()

	getSceneNode().get_node("MainWindow/Overlay/MainText").position.y = 60
	var files = list_files_in_directory("res://art/endings")
	var endingFiles = search_ending_files(str(endingNumber),files)
	endingFiles.sort()
	if endingsSeen.has(currentEnding):
		add_skip()
	for i in endingFiles.size():
		# have to add a lot of checks here for ending being skipped, since this runs in a singleton we can't unload Globals
		if Globals.endingInProgress == true:
			if is_instance_valid(imageNode):
				imageNode.texture = load("res://art/endings/" + (endingFiles[i].trim_suffix(".import")))		
				await fade_in(imageNode)
				#await fade_in(imageNode).completed
			messageWindowInstance.details_message_window((endingFiles[i].trim_suffix(".png.import")), "endings")
			await self.textComplete
			await get_tree().create_timer(4).timeout
			await fade_out(imageNode)
	# If the current ending hasn't been seen before, add it to the list of seen endings
	if !endingsSeen.has(currentEnding):
		endingsSeen.append(currentEnding)
		Globals.settingsSaveInstance.set_value("settings", "endingsSeen", endingsSeen)
		Globals.settingsSaveInstance.save(settings_path)
		check_endings()	
	if getLocationName() != "MainMenu":
		Globals.getSceneNode().get_node("MainWindow/LocationImage/Interactives/BigBlocker").visible = false
	# Skip credits if you're viewing from the gallery
	if Globals.endingScreenLaunch == true:
		Globals.endingInProgress = false
		var error_code = get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		if error_code != 0:
			print("ERROR: ", error_code)
	# Cut to credits if this is a normal ending
	elif Globals.endingInProgress == true:
		Globals.endingInProgress = false
		var error_code = get_tree().change_scene_to_file("res://scenes/Credits.tscn")
		if error_code != 0:
			print("ERROR: ", error_code)


func check_endings():
	if all_endings_seen():
		print("You got them all!")
	else:
		print("You still don't have them all.")
	

func all_endings_seen():
	for n in range(1,11):
		if !Globals.endingsSeen.has(n):
			print("You didn't get them all yet.")
			return false
		else:
			print("You got them all!")
			return true

# Add skip button
func add_skip():
	var skipNode = TextureRect.new()
	skipNode.texture = load("res://art/menu/skip.png")
	skipNode.set_position(Vector2(1164,636))
	skipNode.name = "SkipNode"
	getSceneNode().add_child(skipNode)
	var loadedSkipNode = getSceneNode().get_node("SkipNode")
	loadedSkipNode.scale = Vector2(float(currentScale), float(currentScale))
	loadedSkipNode.set_position(Vector2((loadedSkipNode.position.x * float(currentScale)), (loadedSkipNode.position.y * float(currentScale))))
	loadedSkipNode.connect("gui_input", Callable(self, "_on_Skip_mouse_click"))
	skipNode.visible = true

func _on_Skip_mouse_click(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			endingSkipped = true
			print(getSceneNode())
			Globals.messageWindowTextComplete = true
			Globals.messageWindowCurrentSegment = 0
			Globals.currentEnding = null
			Globals.currentDetailNode = null
			Globals.currentDetailType = null
			Globals.endingInProgress = false
			var error_code = get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

# Fade In/Out

func fade_out(node):
	if is_instance_valid(node):
		node.material = fadeMaterial
		var useSpeed = defaultFadeOutSpeed
		while node.material.get_shader_parameter("darkness") > 0.005:
			await get_tree().create_timer(0.1).timeout
			if node.material.get_shader_parameter("darkness") < 0.1:
				useSpeed = useSpeed * 0.95
			var newOpacity = node.material.get_shader_parameter("darkness") * useSpeed
			if is_instance_valid(node):
				node.material.set_shader_parameter("darkness", newOpacity)

func fade_in(node):
	if is_instance_valid(node):
		node.material = fadeMaterial
		node.material.set_shader_parameter("darkness", 0.005)
		while node.material.get_shader_parameter("darkness") < 1:
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(node) and node.material == fadeMaterial:
				var newOpacity = node.material.get_shader_parameter("darkness") * defaultFadeInSpeed
				node.material.set_shader_parameter("darkness", newOpacity)

func actor_fade_in(node):
	if is_instance_valid(node):
		node.modulate = Color(1,1,1,0)
		node.visible = true
		var currentOpacity = 0.005
		while currentOpacity < 1:
			currentOpacity = currentOpacity * 1.5
			if is_instance_valid(node):
				node.modulate = Color(1,1,1,currentOpacity)
			await get_tree().create_timer(0.1).timeout

func actor_fade_out(node):
	if is_instance_valid(node):
		var currentOpacity = node.modulate.a
		var useSpeed = defaultFadeOutSpeed
		while currentOpacity > 0.005:
			if currentOpacity < 0.1:
				useSpeed = useSpeed * 0.85
			currentOpacity = currentOpacity * useSpeed
			if is_instance_valid(node):
				node.modulate = Color(1,1,1,currentOpacity)
			await get_tree().create_timer(0.1).timeout
		if is_instance_valid(node):
			node.modulate.a = 0
		if is_instance_valid(node):
			node.visible = false

# Save Stuff

func loadLastSave():
	var files = list_files_in_directory(save_dir)
	var fileAgeDict = {}
	var fileAgeArray = []
	for i in files:
		var age = FileAccess.get_modified_time(save_dir + i)
		fileAgeArray.append(age)
		fileAgeDict[str(age)] = i
	fileAgeArray.sort()
	var lastSave = str(fileAgeArray[fileAgeArray.size() - 1])	
	var savePath = save_dir + fileAgeDict[lastSave]
	load_game_data(savePath)

func saveSetting(section, key, value):
		settingsSaveInstance.set_value(section, key, value)
		settingsSaveInstance.save(Globals.settings_path)

func create_save():
	Globals.settingsSaveInstance.set_value("info", "OS", OS.get_name())
	Globals.player_id = UUID.generate()
	Globals.settingsSaveInstance.set_value("info", "player_id", Globals.player_id)
	Globals.settingsSaveInstance.set_value("settings", "currentWidth", get_window().get_size().x)
	Globals.settingsSaveInstance.set_value("settings", "currentHeight", get_window().get_size().y)
	Globals.settingsSaveInstance.set_value("settings", "fullscreenEnabled", false)
	Globals.settingsSaveInstance.set_value("settings", "currentScale", 1)
	Globals.settingsSaveInstance.set_value("settings", "soundEnabled", true)
	Globals.settingsSaveInstance.set_value("settings", "telemetryEnabled", true)
	Globals.settingsSaveInstance.set_value("settings", "hardcodeEnabled", false)
	Globals.settingsSaveInstance.set_value("settings", "endingsSeen", endingsSeen)
	Globals.settingsSaveInstance.set_value("settings", "creditsWatched", creditsWatched)
	Globals.settingsSaveInstance.set_value("settings", "customMouseSize", customMouseSize)
	Globals.settingsSaveInstance.save(Globals.settings_path)

func load_settings():
	Globals.player_id = Globals.settingsSaveInstance.get_value("info", "player_id")
	Globals.currentWidth = Globals.settingsSaveInstance.get_value("settings", "currentWidth")
	Globals.currentHeight = Globals.settingsSaveInstance.get_value("settings", "currentHeight")
	Globals.fullscreenEnabled = Globals.settingsSaveInstance.get_value("settings", "fullscreenEnabled")
	Globals.currentScale = Globals.settingsSaveInstance.get_value("settings", "currentScale")
	Globals.soundEnabled = Globals.settingsSaveInstance.get_value("settings", "soundEnabled")
	Globals.telemetryEnabled = Globals.settingsSaveInstance.get_value("settings", "telemetryEnabled")
	Globals.hardcodeEnabled = Globals.settingsSaveInstance.get_value("settings", "hardcodeEnabled")
	Globals.endingsSeen = Globals.settingsSaveInstance.get_value("settings", "endingsSeen")
	Globals.creditsWatched = Globals.settingsSaveInstance.get_value("settings", "creditsWatched")
	Globals.customMouseSize = Globals.settingsSaveInstance.get_value("settings", "customMouseSize")

# Telemetry
# Keeping as an example of an Azure POST request

func post_data(eventtype, data):
	if Globals.telemetryEnabled == true:
		var host = "disabled"
		var table = "telemetry"
		var sas = "disabled"
		var uri = host + table + sas
		var _data := {
		"PartitionKey" : str(Globals.player_id),
		"RowKey" : getNowUTC(),
		"EventType" : eventtype,
		"Data" : data
		}
		var query = JSON.stringify(_data)
		var headers = ["x-ms-date: " + str(getNowUTC()),"x-ms-version: 2016-05-31","Accept: application/json;odata=nometadata","Content-Length: " + str(query.length()),"Content-Type: application/json"]
		var error = $HTTPNode.request(uri, headers, true, HTTPClient.METHOD_POST, query)
		if error != OK:
			print("An error occurred.")
			print(error)
		return error
	else:
		var error = "Telemetry disabled."
		return error

# Time

func getNow():
	var time = Time.get_datetime_dict_from_system()
	var nameweekday= ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var dayofweek = time["weekday"]   # from 0 to 6 --> Sunday to Saturday
	var dateday = time["day"]                         #   1-31
	var month= time["month"]               #   1-12
	var year= time["year"]             
	var hour= time["hour"]                     #   0-23
	var minute= time["minute"]             #   0-59
	var second= time["second"]             #   0-59	
	var dateRFC1123 = "%s, %02d %s %d %02d:%02d:%02d GMT" % [nameweekday[dayofweek], dateday, namemonth[month-1], year, hour, minute, second]
	return dateRFC1123

func getNowUTC():
	var unix_time: float = Time.get_unix_time_from_system()
	var unix_time_int: int = unix_time
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	var ms: int = (unix_time - unix_time_int) * 1000.0
	var result := "%s-%s-%s %02d:%02d:%02d:%03d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, ms]
	return result


func hungerTimer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(60)
	timer.connect("timeout", Callable(self, "on_timeout"))
	timer.name = "HungerTimer"
	add_child(timer)
	timer.start()

func on_timeout():
	var oldTimer = get_node("root/globals/HungerTimer")
	if oldTimer != null:
		oldTimer.queue_free()
	Globals.hungerMinutes += 1
	print(Globals.hungerMinutes)
	hungerTimer()

# Click Events


func _on_Choice0_mouse_entered():
	var text = "[color=lime]" + str(getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice0").text) + "[/color]"
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice0").set_bbcode(text)

func _on_Choice0_mouse_exited():
	var text = getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice0").text.replace("[color=lime]","").replace("[/color]","")
	get_node("MainWindow/Overlay/MainText/Choices/Choice0").set_bbcode(text)

func _on_Choice0_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "0")
			Globals.choiceActive = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Body").visible = true
			getSceneNode().get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice1_mouse_entered():
	var text = "[color=lime]" + str(getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice1").text) + "[/color]"
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice1").set_bbcode(text)

func _on_Choice1_mouse_exited():
	var text = getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice1").text.replace("[color=lime]","").replace("[/color]","")
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice1").set_bbcode(text)

func _on_Choice1_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "1")
			Globals.choiceActive = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Body").visible = true
			getSceneNode().get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice2_mouse_entered():
	var text = "[color=lime]" + str(getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice2").text) + "[/color]"
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice2").set_bbcode(text)

func _on_Choice2_mouse_exited():
	var text = getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice2").text.replace("[color=lime]","").replace("[/color]","")
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice2").set_bbcode(text)

func _on_Choice2_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "2")
			Globals.choiceActive = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Body").visible = true
			getSceneNode().get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Choices").visible = false

func _on_Choice3_mouse_entered():
	var text = "[color=lime]" + str(getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice3").text) + "[/color]"
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice3").set_bbcode(text)

func _on_Choice3_mouse_exited():
	var text = getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice3").text.replace("[color=lime]","").replace("[/color]","")
	getSceneNode().get_node("MainWindow/Overlay/MainText/Choices/Choice3").set_bbcode(text)

func _on_Choice3_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			Globals.emit_signal("choiceMade", "3")
			Globals.choiceActive = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Body").visible = true
			getSceneNode().get_node("MainWindow/Overlay/MainText/ChoiceLabel").visible = false
			getSceneNode().get_node("MainWindow/Overlay/MainText/Choices").visible = false

func test_internet():
	var error = $HTTPTestNode.request("https://www.google.com/")
	if error != OK:
		print("An error occurred.")
		print(error)

func _http_test_request_completed(result, response_code, headers, body):
	if response_code == 200:
		internetActive = true
	else:
		internetActive = false
		telemetryEnabled = false
