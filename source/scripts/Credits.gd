extends Node

var defaultFadeInSpeed = 1.2
var defaultCreditFadeInSpeed = 1.5
var defaultFadeOutSpeed = 0.85
var defaultCreditFadeOutSpeed = 0.9
var threadPause
var thread1In
var thread1Out
var time = 0.0
var currentRoll = 0

func _process(delta):
	time += delta
	if time > 3 or Globals.creditsWatched == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if currentRoll < 10:
			get_node("MainWindow/MainMenu").visible = false
			get_node("MainWindow/MainMenu").modulate.a = 0

func reset_time():
	time = 0.0

func _ready():
	Globals.update_size()
	var node = get_node("MainWindow")
	setStaringOpacity(node)
	var menuButtonNode = get_node("MainWindow/MainMenu")
	menuButtonNode.visible = false
	# 0
	var node0 = get_node("MainWindow/0")
	await get_tree().create_timer(2).timeout
	await fade_in(node0)
	var node0credit = get_node("MainWindow/0/Credit")
	play_intro()
	await fade_in_credit(node0credit)
	await get_tree().create_timer(5).timeout
	await fade_out(node0)
	
	# 1
	currentRoll = 1
	var node1 = get_node("MainWindow/1")
	await fade_in(node1)
	await get_tree().create_timer(2).timeout
	var node1credit = get_node("MainWindow/1/Credit")
	await fade_in_credit(node1credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node1)
	
	# 2
	currentRoll = 2
	var node2 = get_node("MainWindow/2")	
	await fade_in(node2)
	await get_tree().create_timer(2).timeout
	var node2credit = get_node("MainWindow/2/Credit")
	await fade_in_credit(node2credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node2)
	
	# 3
	currentRoll = 3
	var node3 = get_node("MainWindow/3")
	await fade_in(node3)
	await get_tree().create_timer(2).timeout
	var node3credit = get_node("MainWindow/3/Credit")
	await fade_in_credit(node3credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node3)
	
	# 4
	currentRoll = 4
	var node4 = get_node("MainWindow/4")
	await fade_in(node4)
	await get_tree().create_timer(2).timeout
	var node4credit = get_node("MainWindow/4/Credit")
	await fade_in_credit(node4credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node4)
	
	# 5
	currentRoll = 5
	var node5 = get_node("MainWindow/5")
	await fade_in(node5)
	await get_tree().create_timer(2).timeout
	var node5credit = get_node("MainWindow/5/Credit")
	await fade_in_credit(node5credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node5)
	
	# 6
	currentRoll = 6
	var node6 = get_node("MainWindow/6")
	await fade_in(node6)
	await get_tree().create_timer(2).timeout
	var node6credit = get_node("MainWindow/6/Credit")
	await fade_in_credit(node6credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node6)
	
	# 7
	currentRoll = 7
	var node7 = get_node("MainWindow/7")
	await fade_in(node7)
	await get_tree().create_timer(2).timeout
	var node7credit = get_node("MainWindow/7/Credit")
	await fade_in_credit(node7credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node7)
	
	# 8
	currentRoll = 8
	var node8 = get_node("MainWindow/8")
	await fade_in(node8)
	await get_tree().create_timer(2).timeout
	var node8credit = get_node("MainWindow/8/Credit")
	await fade_in_credit(node8credit)
	await get_tree().create_timer(3).timeout
	await fade_out(node8)
	
	# 9
	currentRoll = 9
	var node9 = get_node("MainWindow/9")
	await fade_in(node9)
	await get_tree().create_timer(2).timeout
	var node9credit = get_node("MainWindow/9/Credit")
	await fade_in_credit(node9credit)
	await get_tree().create_timer(1).timeout
	
	var node9credit1 = get_node("MainWindow/9/Credit/1")
	await fade_in_credit(node9credit1)
	await get_tree().create_timer(1).timeout
	await fade_out_credit(node9credit1)
	var node9credit2 = get_node("MainWindow/9/Credit/2")
	await fade_in_credit(node9credit2)
	await get_tree().create_timer(2).timeout
	await fade_out_credit(node9credit2)
	
	var node9credit3 = get_node("MainWindow/9/Credit/3")
	await fade_in_credit(node9credit3)
	
	currentRoll = 10
	await get_tree().create_timer(4).timeout
	await fade_out(node9)
	var endNode = get_node("MainWindow/TheEnd")
	await fade_in(endNode)
	await get_tree().create_timer(3).timeout
	menuButtonNode.visible = true
	Globals.creditsWatched = true
	fade_in(menuButtonNode)

func _input(event):
	if event is InputEventMouseMotion:
		reset_time()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and currentRoll > 1 and currentRoll < 10:
			get_node("MainWindow/MainMenu").visible = true
			get_node("MainWindow/MainMenu").modulate.a = 1


func setStaringOpacity(node):
	for N in node.get_children():
		if N.get_child_count() > 0:
			if N is TextureRect:
				N.modulate = Color(1,1,1,0)
			setStaringOpacity(N)
		else:
			if N is TextureRect:
				N.modulate = Color(1,1,1,0)

func pause(seconds):
	await get_tree().create_timer(seconds).timeout

func fade_in(node):
		var currentOpacity = 0.005
		while currentOpacity < 1:
			currentOpacity = currentOpacity * defaultFadeInSpeed
			node.modulate = Color(1,1,1,currentOpacity)
			await get_tree().create_timer(0.1).timeout
			
func fade_in_credit(node):
		var currentOpacity = 0.005
		while currentOpacity < 1:
			currentOpacity = currentOpacity * defaultCreditFadeInSpeed
			if currentOpacity > 1:
				currentOpacity = 1
			node.modulate = Color(1,1,1,currentOpacity)
			await get_tree().create_timer(0.1).timeout

func fade_out(node):
		var currentOpacity = node.modulate.a
		var useSpeed = defaultFadeOutSpeed
		while currentOpacity > 0.005:
			if currentOpacity < 0.1:
				useSpeed = useSpeed * 0.95
			currentOpacity = currentOpacity * useSpeed
			node.modulate = Color(1,1,1,currentOpacity)
			await get_tree().create_timer(0.1).timeout
		node.modulate.a = 0

func fade_out_credit(node):
		var currentOpacity = node.modulate.a
		var useSpeed = defaultCreditFadeOutSpeed
		while currentOpacity > 0.005:
			if currentOpacity < 0.1:
				useSpeed = useSpeed * 0.95
			currentOpacity = currentOpacity * useSpeed
			node.modulate = Color(1,1,1,currentOpacity)
			await get_tree().create_timer(0.1).timeout

func _on_MainMenu_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var error_code = get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
			if error_code != 0:
				print("ERROR: ", error_code)

func play_intro():
	var audioNode = Globals.getSceneNode().get_node("AudioStreamPlayer")
	var sound : AudioStream = load("res://sounds/newintro.wav")
	audioNode.set_stream(sound)
	if Globals.soundEnabled == true:
		audioNode.play()
