extends Node2D


@onready var left_marker: Marker2D = $LeftMarker
@onready var right_marker: Marker2D = $RightMarker
@onready var next_planet_marker: Marker2D = $NextplanetMarker
@onready var gameover_area: = $StaticBody2D/GameoverArea
@onready var gameover_label: Label = $CanvasLayer/Gameover
@onready var countdown: Label = $CanvasLayer/CountDown
@onready var launch_preview: Line2D = $LaunchPreview

var planet_scene := preload("res://planet.tscn")
var current_planet
var next_planet
var gameoverTime = 5.00
var gameoverTimer = gameoverTime
var isGameover = false
var launch_power: float = 0.0
var max_launch_power:float = 1000
var is_charging: bool = false
var charge_start_mouse_pos: Vector2 = Vector2.ZERO
var planet_locked_position: Vector2 = Vector2.ZERO
var CLICK_DELAY: float = 0.3 


func _physics_process(delta: float) -> void:
	if isGameover or not current_planet:
		return
	
		# Move planet with mouse ONLY when not charging
	if current_planet.gravity_scale == 0 and not is_charging:
		current_planet.global_position.x = clamp(
			get_global_mouse_position().x,
			left_marker.global_position.x + current_planet.size * 10,
			right_marker.global_position.x - current_planet.size * 10
		)
		
	if Input.is_action_just_pressed("launch"):
		is_charging = true
		charge_start_mouse_pos = get_global_mouse_position()
		planet_locked_position = current_planet.global_position
		launch_power = 0.0
		launch_preview.visible = true
		
	if is_charging and Input.is_action_pressed("launch"):
		var mouse_pos = get_global_mouse_position()
		var pull_vector = charge_start_mouse_pos - mouse_pos  # How far we pulled back
		
		# Power based on pull distance
		launch_power = clamp(pull_vector.length() * 2, 0, max_launch_power)
	# Launch direction is OPPOSITE of pull
		var launch_direction = pull_vector.normalized()
		
		# Update preview line
		launch_preview.clear_points()
		launch_preview.add_point(planet_locked_position)
		launch_preview.add_point(planet_locked_position + launch_direction * (launch_power / max_launch_power) * 200)
		
		# Color based on power
		var power_ratio = launch_power / max_launch_power
		launch_preview.default_color = Color(1.0, 1.0 - power_ratio, 1.0 - power_ratio)

		
	if is_charging and Input.is_action_just_released("launch"):
		launch_planet()
		is_charging = false
		launch_power = 0.0
		launch_preview.visible = false
		
		current_planet = null
		await get_tree().create_timer(CLICK_DELAY).timeout
		current_planet = next_planet
		current_planet.global_position = (left_marker.global_position + right_marker.global_position) / 2
		next_planet = create_planet(next_planet_marker.global_position)
		

func create_planet(position):
	var planet = planet_scene.instantiate()
	planet.disable_physics()
	planet.global_position = position
	planet.size = randi_range(1,4)
	add_child(planet)
	return planet

func launch_planet():
	current_planet.enable_physics()
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - current_planet.global_position).normalized()
	current_planet.apply_central_impulse(direction * launch_power)

func update_launch_preview():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - current_planet.global_position).normalized()
	var power_ratio = launch_power / max_launch_power
	
	launch_preview.clear_points()
	launch_preview.add_point(current_planet.global_position)
	launch_preview.add_point(current_planet.global_position + direction * power_ratio * 200)
	launch_preview.visible = true

func _ready():
	current_planet = create_planet((left_marker.global_position + right_marker.global_position) / 2)
	next_planet = create_planet(next_planet_marker.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isGameover:
		return 
	for body in gameover_area.get_overlapping_bodies():
		if body.is_in_group("planets"):
			print_debug("in");
			gameoverTimer -= delta
			countdown.visible = true
			Gamemaster.update_count_down.emit(gameoverTimer)
			if (gameoverTimer <= 0):
				Gameover();
			return
	gameoverTimer = gameoverTime
	countdown.visible = false
	
func Gameover():
	isGameover = true
	gameover_label.visible = true
	
