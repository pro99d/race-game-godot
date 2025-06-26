extends Control

func _ready() -> void:
	pass


func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_settings_button_down() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_exit_button_down() -> void:
	print("выход")
	get_tree().quit()
