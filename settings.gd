extends Control

func _ready() -> void:
	$players_slider.value = Global.players_count

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func _players_changed(value_changed: bool) -> void:
	Global.players_count = $players_slider.value


func _on_debug_pressed() -> void:
	Global.debug = not Global.debug

func _process(delta: float) -> void:
	$players_label.text = "Игроков: %d" % Global.players_count
