class_name Demo1 extends Node2D

@onready var test_button: Button = %TestButton

func _ready():
	test_button.button_down.connect(_on_test_button_button_down)
	test_button.button_up.connect(_on_test_button_button_up)

func _on_area_2d_area_entered(area):
	pass

func _on_area_2d_body_entered(body):
	pass

func _on_area_2d_body_exited(body):
	pass

func _on_area_2d_area_exited(area):
	pass

func _on_test_button_pressed():
	pass

func _on_test_button_button_down():
	pass

func _on_test_button_button_up():
	pass
