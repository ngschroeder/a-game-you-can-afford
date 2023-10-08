extends Node

var sceneNode
var commandLine
var command

# This whole script was for the idea of having the user type into the game, like the original
# Quest for Glory or King's Quest games. Abandonded the idea because of the direction the game went.
# Keeping this for reference because it worked.

func _on_TextEdit_gui_input(event):
	if event.as_text() == "Enter" and event.is_pressed() == true:
		# Get the entered text, strip the edges, and make lowercase
		commandLine = Globals.getSceneNode().get_node("MainWindow/Overlay/Command/TextEdit")
		command = commandLine.text.trim_suffix("\n").trim_suffix("\r").strip_edges().to_lower()
		Globals.emit_signal("choiceMade", command)
		var bad_chars = '?!;:\\/|"`\''
		for c in bad_chars:
			command = command.replace(c, '')
		# Reset the command text prompt
		commandLine.text = ""
		print(command)
		commandLine.get_parent().visible = false
		Globals.post_data("text_input", command)
		# Disable the line above and enable the lines below to enable GPT-3 conversations....
		"""
		Globals.post_gpt3_data(command)
		await Globals.aiAnswered
		print(Globals.aiText)
		Globals.messageWindowInstance.details_message_window(Globals.aiText, null)
		#yield(Globals, "textComplete")
		"""

func _get_SceneNode():
	sceneNode = get_tree().get_root().get_child(1)
	commandLine = sceneNode.get_node("Overlay/Command/TextEdit")
