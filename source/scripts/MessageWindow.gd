extends Node

var itemImage
var itemBody
var messageText
var myCount = 0
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()

func details_message_window(itemInfo, type):
	var thisScene = Globals.getSceneNode()
	var messageWindow = thisScene.get_node("MainWindow/Overlay/MainText/Body")
	var thisItem
	var dialog_array
	var rawTextArray

	if is_instance_valid(messageWindow):
		Globals.currentDetailNode = itemInfo
		Globals.currentDetailType = type
		messageWindow.get_parent().visible = true
		Input.set_custom_mouse_cursor(Globals.pointerarrow)
		# AI Stuff
		if type == null:
			rawTextArray = do_gpt3_response(itemInfo)
			dialog_array = parse_text(rawTextArray)
		else:
			if itemInfo is String:
				thisItem = itemInfo
			else:
				thisItem = itemInfo.name
			var textFileName = "res://text/" + type + "/" + thisItem + ".txt"
			rawTextArray = Globals.load_file(textFileName)
			dialog_array = parse_text(rawTextArray)
		# When the game crashes here it's because it's looking for files or segments that are missing.
		if "GAMEOVER" in dialog_array[int(Globals.messageWindowCurrentSegment)]:
			Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
			Globals.messageWindowCurrentSegment = 0
			Globals.messageWindowTextComplete = true
			Globals.clickDisabled = true
			Globals.do_ending(Globals.currentEnding)
			return
		if "CHOICES" in dialog_array[int(Globals.messageWindowCurrentSegment)]:		
			var choiceArray = Array(dialog_array[int(Globals.messageWindowCurrentSegment)].split("\n"))
			choiceArray.erase("CHOICES")
			Globals.getSceneNode().get_node("MainWindow/Overlay/MainText").visible = false
			Globals.messageWindowCurrentSegment = 0
			Globals.messageWindowTextComplete = true
			Globals.choiceActive = true
			Globals.choice_parser(choiceArray)
			return
		messageWindow.set_text(dialog_array[(Globals.messageWindowCurrentSegment)])
		if "SMACK" in dialog_array[(Globals.messageWindowCurrentSegment)]:
			Globals.do_smack()
			Globals.play_smack_sound()
			Globals.alarmSmackCount += 1
			if Globals.alarmSmackCount == 3:
				Globals.stop_alarm()
		if "*PUNCH*" in dialog_array[(Globals.messageWindowCurrentSegment)]:
			var random_value = rng.randi_range(1,2)
			var soundfile = "res://sounds/punch" + str(random_value) + ".wav"
			Globals.do_smack()
			Globals.play_sound(soundfile)
		Globals.messageWindowCurrentSegment += 1
		if dialog_array.size() == Globals.messageWindowCurrentSegment:
			Globals.messageWindowTextComplete = true
			Globals.messageWindowCurrentSegment = 0
			Globals.currentDetailNode = null
			Globals.currentDetailType = null
		else:
			Globals.messageWindowTextComplete = false
		Globals.messageWindowOpen = true

func do_gpt3_response(text):
	var dialog_array = []
	var words = text.split(" ")
	var total_line_count = 0
	var line = ""
	var segment_line_number = 0
	var i = 0
	while i < words.size():
		if line.length() + words[i].length() + 1 > 48:
			dialog_array.insert(total_line_count, line)
			total_line_count += 1
			segment_line_number += 1
			line = ""
			if segment_line_number > 4:
				dialog_array.insert(total_line_count, "------------------------------------------------")
				total_line_count += 1
				segment_line_number = 0
		line = line + words[i] + " "
		i += 1
		if i == words.size():
			var endstring = "------------------------------------------------"
			dialog_array.insert(total_line_count, line)
			dialog_array.insert((total_line_count + 1), endstring)
	return dialog_array

func item_message_window(itemNode):
	var file
	var thisScene = Globals.getSceneNode()
	var itemTextWindow = thisScene.get_node("MainWindow/Overlay/ItemText/ItemBody")
	var itemNodeName = ""
	itemTextWindow.get_parent().visible = true
	# Set the image
	if itemNode is String:
		itemNodeName = itemNode
	else:
		itemNodeName = itemNode.name
	var itemTexture = "res://art/object/" + itemNodeName + "-inv.png"
	var itemTextFileName = "res://text/object/" + itemNodeName + "-inv.txt"
	file = FileAccess.open(itemTextFileName, FileAccess.READ)
	var text = file.get_as_text()
	itemTextWindow.text = text
	itemTextWindow.get_parent().get_node("ItemImage").texture = load(itemTexture)
	# Temporarily setting text to complete to close window
	# This has turned into a "why is this here?" that will probably break the game if removed
	Globals.messageWindowTextComplete = true
	Globals.messageWindowOpen = true
  
func parse_text(rawTextArray):
	var returnArray = []
	var textString = ""
	var index = 0
	var n = 0

	while n < rawTextArray.size():
		if rawTextArray[n] != "------------------------------------------------":
			textString = textString + rawTextArray[n] + "\n"
		else:
			returnArray.insert(index, textString)
			textString = ""
			index += 1
		n += 1
	return returnArray
