extends RigidBody2D

var mouse_inside = false
var dragging = false

var thumped = false

var is_left = false
var ballsize = 1.0

onready var myworld = get_parent()

func _ready():
	GameEvents.connect("let_go", self, "_on_let_go")
	pump()
	
func pump():
	$Tween.interpolate_property($Sprite, "scale", Vector2(ballsize * 0.5, ballsize * 0.5), Vector2(ballsize, ballsize), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()

func _input(event):
	if event.is_action_pressed("drag"):
		if mouse_inside and not myworld.is_dragging():
			dragging = true
			myworld.set_dragging(self)
	if event.is_action_released("drag"):
		if dragging:
			dragging = false
			myworld.release_dragging()

func _process(delta):
	if Input.is_action_pressed("drag") and dragging:
		position.x = clamp(get_global_mouse_position().x, myworld.get_min_x(is_left), myworld.get_max_x(is_left))

func set_size(size:float):
	$Sprite.scale = Vector2(size, size)
	$CollisionShape2D.scale = Vector2(size, size)
	mass = 5 * PI * size
	ballsize = size

func _on_let_go():
	mode = RigidBody2D.MODE_RIGID
	

func _on_Ball_mouse_entered():
	mouse_inside = true

func _on_Ball_mouse_exited():
	mouse_inside = false


func _on_Ball_body_entered(body):
	if body.is_in_group("latte"):
		if not thumped:
			$Thump.play()
			thumped = true
			GameEvents.emit_signal("touched_latte")


