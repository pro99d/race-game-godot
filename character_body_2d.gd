extends CharacterBody2D

@export var player_id: int = 1:
	set(value):
		player_id = clampi(value, 1, 4)

# Physics parameters ported and adapted from the original game
@export_group("Speed")
@export var max_speed = 900.0          # px/sec (Original: 15 px/frame)
@export var acceleration = 720.0       # px/sec^2 (Original: 0.2)
@export var med_speed_threshold = 228.0  # px/sec (Original: 3.8)
@export var high_speed_threshold = 456.0 # px/sec (Original: 7.6)
@export var med_speed_accel = 1440.0     # px/sec^2 (Original: 0.4)
@export var high_speed_accel = 2160.0    # px/sec^2 (Original: 0.6)
@export var reverse_accel_factor = 1.0 / 3.0
@export_group("Friction")
@export var friction = 0.05        # Corresponds to 5% speed loss per frame at 60fps
@export_group("Turning")
@export var turn_magic_constant = 13.96  # Derived from original formula: sqrt((g*mu/4)*60)
var on_track = true
var current_speed = 0.0
@export var health = 10.0
var checkpoint =false
var laps = 0

@onready var sprite = $Sprite2D
var sprites = ["red", "orange", "blue", "green"]
var time_elapsed = 0.0

func _ready() -> void:
	add_to_group("players")
	var path = "res://sprites/%s_car.png" % sprites[player_id-1]
	sprite.texture = load(path)
	
func calculate_approaching_speed(speed_a: Vector2, pos_a: Vector2i, speed_b: Vector2, pos_b: Vector2i) -> float:
	var p_ab = pos_b - pos_a
	var distance = p_ab.length()
	if distance == 0:
		return 0
	var direction = p_ab / distance  
	var relative_velocity = speed_b - speed_a 
	var approaching_speed = relative_velocity.dot(direction)
	return approaching_speed

func _process(delta: float) -> void:
	time_elapsed+=delta

func _physics_process(delta: float) -> void:
	var turn_direction = Input.get_axis("p%d_left" % player_id, "p%d_right" % player_id)
	var move_direction = Input.get_axis("p%d_down" % player_id, "p%d_up" % player_id)

	# --- Acceleration/Deceleration ---
	var current_ax = acceleration
	if current_speed > med_speed_threshold:
		if current_speed <= high_speed_threshold:
			current_ax = med_speed_accel
		else:
			current_ax = high_speed_accel
		
	if move_direction > 0:
		current_speed = move_toward(current_speed, max_speed, current_ax * delta)
	elif move_direction < 0:
		current_speed = move_toward(current_speed, -max_speed / 2.0, current_ax * reverse_accel_factor * delta)

	if on_track:
		current_speed -= current_speed*0.05
	else:
		current_speed -= current_speed*0.8


	# --- Turning ---
	if abs(current_speed) > 0.0:
		var turn_rate_deg_sec = sign(current_speed) * sqrt(abs(current_speed)) * turn_magic_constant
		rotation += turn_direction * deg_to_rad(turn_rate_deg_sec) * delta
	
	# --- Apply Velocity ---
	velocity = Vector2.from_angle(rotation) * current_speed
	# move_and_slide() -> move_and_collide() с кастомной обработкой
	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider().is_in_group("players"):
		var other = collision.get_collider()
		var speed_b = other.velocity
		var pos_b = other.position
		var approaching_speed = calculate_approaching_speed(velocity, position, speed_b, pos_b)
		health-= sign(approaching_speed)*approaching_speed
		other.health -= sign(approaching_speed)*approaching_speed
		on_player_collision()
		if collision.get_collider().has_method("on_player_collision"):
			collision.get_collider().on_player_collision()
	position.x = clamp(position.x, 0, 1366)
	position.y = clamp(position.y, 0, 768)


func on_player_collision():
	current_speed *= -0.5
