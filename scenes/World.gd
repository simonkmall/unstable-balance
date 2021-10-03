extends Node2D

var points = 0

var dragged_object = null

var left_ball = null
var right_ball = null
var latte = null

onready var ball_scene = preload("res://scenes/Ball.tscn")
onready var latte_scene = preload("res://scenes/Latte.tscn")

onready var music_player = [$Music1, $Music2, $Music3, $Music4]
var current_music = 0

var countdown = 5
var countdown_running = false

func _ready():
	randomize()
	generate()
	GameEvents.connect("touched_latte", self, "_on_touched_latte")
	music_player[current_music].volume_db = 0.0
	music_player[current_music].play()
	
func generate():
	countdown = 5
	countdown_running = false
	remove_all_balls()
	left_ball = add_ball(Vector2(rand_range($Left.position.x, $MiddleLeft.position.x), $MiddleLeft.position.y), true)
	right_ball = add_ball(Vector2(rand_range($MiddleRight.position.x, $Right.position.x), $MiddleRight.position.y), false)
	
	if latte:
		latte.queue_free()
	var nl = latte_scene.instance()
	nl.position = Vector2(512, 548)
	add_child(nl)
	latte = nl

func remove_all_balls():
	if left_ball:
		left_ball.queue_free()
		left_ball = null
	if right_ball:
		right_ball.queue_free()
		right_ball = null

func add_ball(pos, is_left):
	var newb = ball_scene.instance()
	newb.position = pos
	newb.set_size(rand_range(0.1, 1.0))
	newb.is_left = is_left
	add_child(newb)
	return newb

func is_dragging():
	return not (dragged_object == null)
	
func set_dragging(obj):
	dragged_object = obj
	$CanvasLayer/Instructions.visible = false

func release_dragging():
	dragged_object = null

func get_min_x(is_left):
	return $Left.position.x if is_left else $MiddleRight.position.x

func get_max_x(is_left):
	return $MiddleLeft.position.x if is_left else $Right.position.x

func _on_Button_pressed():
	$Blip.play()
	GameEvents.emit_signal("let_go")
	$CanvasLayer/Instructions.visible = false

func _on_LattenDetector_body_entered(body):
	if body.is_in_group("latte"):
		GameEvents.emit_signal("fell_down")
		$Countdown.stop()
		$CanvasLayer/CountdownLabel.visible = false
		$Tween.interpolate_property(music_player[current_music], "volume_db", null, -80.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		show_text("Failed!")
		points = 0
		$CanvasLayer/CountLabel.text = "%02d" % [points]
		yield($Tween, "tween_all_completed")
		music_player[current_music].stop()
		current_music = (current_music + 1) % 4
		music_player[current_music].volume_db = 0.0
		music_player[current_music].play()
		generate()


func _on_Countdown_timeout():
	countdown -= 1
	$CanvasLayer/CountdownLabel.text  = "%d" % [countdown]
	if countdown == 0:
		$Countdown.stop()
		$CanvasLayer/CountdownLabel.visible = false
		points += 1
		$CanvasLayer/CountLabel.text = "%02d" % [points]
		show_text("Well Done!")
		generate()

func _on_touched_latte():
	if not countdown_running:
		$Countdown.start()
		countdown_running = true
		$CanvasLayer/CountdownLabel.text  = "%d" % [countdown]
		$CanvasLayer/CountdownLabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$CanvasLayer/CountdownLabel.visible = true

func show_text(text_string):
	$CanvasLayer/CountdownLabel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	$CanvasLayer/CountdownLabel.visible = false
	$CanvasLayer/CountdownLabel.text = text_string
	$CanvasLayer/CountdownLabel.visible = true
	$TextTween.interpolate_property($CanvasLayer/CountdownLabel, "modulate", null, Color(1.0, 1.0, 1.0, 0.0), 1.0, Tween.TRANS_EXPO, Tween.EASE_IN)
	$TextTween.start()
	
