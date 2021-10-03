extends Node2D

func _on_Button_pressed():
	$Blip.play()
	yield($Blip, "finished")
	get_tree().change_scene("res://scenes/World.tscn")


func _on_RigidBody2D_body_entered(body):
	$Blop.play()
