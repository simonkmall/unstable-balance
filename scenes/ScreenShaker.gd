extends Node2D

# Instructions:
# Add Screenshaker Scene to a Camera2D
# Call the start function like so:
# Camera2D/ScreenShaker.start(0.2, 15, 5, 1)

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()

func _ready():
	GameEvents.connect("touched_latte", self, "start")
	
func start(duration = 0.1, frequency = 15, amplitude = 5, priority = 0):
	#camera.offset = Vector2(200, 200)
	if priority < self.priority:
		return
	self.priority = priority
	self.amplitude = amplitude
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	$Duration.start()
	$Frequency.start()
	_new_shake()
	
func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	priority = 0

func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
