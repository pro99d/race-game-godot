extends Node2D
var player_scene = preload("res://player.tscn")
var start_positions = [Vector2(1199.5, 48.0), Vector2(1229.5, 108.0), Vector2(1199.5, 168.0), Vector2(1229.5, 228.0)]
@onready var track = $Track
var players_on_track_count = {} # Словарь для отслеживания, в скольких зонах трека находится игрок
var time_elapsed = 0

func _ready() -> void:
	start_positions.reverse()
	var screen_size = DisplayServer.screen_get_size()
	var players_count = Global.players_count

	for i in range(players_count):
		var player_instance = player_scene.instantiate()
		Global.scores[i]['created'] = true
		player_instance.player_id = i + 1
		players_on_track_count[player_instance.player_id] = 0 # Инициализируем счетчик
		var start_pos = start_positions[i]
		start_pos.y = screen_size.y - start_pos.y
		player_instance.position = start_pos
		player_instance.rotation_degrees = -90
		add_child(player_instance)

func _process(delta: float) -> void:
	time_elapsed+=delta
	$fps_label.text = "fps: %d" % round(1/delta)

func end_game():
	for i in range(Global.players_count):
		Global.scores[i]['created'] = false
	get_tree().change_scene_to_file("res://menu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_exit"):
		end_game()

func _on_body_entered(body):
	# Проверяем, что в зону вошел именно игрок
	if body.is_in_group("players"):
		body.on_track = true
func _on_body_exited(body):
	# Проверяем, что из зоны вышел именно игрок
	if body.is_in_group("players"):
		body.on_track = false

func _body_finished(body: Node2D) -> void:
	if body.is_in_group("players"):
		if body.checkpoint:
			body.laps+=1


func _checkpoint(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.checkpoint = true
