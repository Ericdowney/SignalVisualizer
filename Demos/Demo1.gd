class_name Demo1 extends Node2D

var original_position := Vector2(200, 324)
var area_entered_position := Vector2(800, 100)
var body_entered_position := Vector2(800, 500)

func _ready():
	$Area2D.position = original_position

func _on_area_2d_area_entered(area):
	_move_to(area_entered_position)

func _on_area_2d_body_entered(body):
	_move_to(body_entered_position)

func _on_area_2d_body_exited(body):
	_move_to(original_position)

func _on_area_2d_area_exited(area):
	_move_to(original_position)

func _move_to(new_position: Vector2):
	var tween = create_tween()
	tween.tween_property($Area2D, "position", new_position, 2)
	tween.play()
