extends Node2D


@onready var left_marker: Marker2D = $LeftMarker
@onready var right_marker: Marker2D = $RightMarker
@onready var next_block_marker: Marker2D = $NextBlockMarker
@onready var gameover_area: = $StaticBody2D/GameoverArea
@onready var gameover_label: Label = $CanvasLayer/Gameover
@onready var countdown: Label = $CanvasLayer/CountDown

var block_scene := preload("res://block.tscn")
var current_block
var next_block
var gameoverTime = 5.00
var gameoverTimer = gameoverTime
var isGameover = false
var CLICK_DDELAY = 0.3


func _physics_process(delta: float) -> void:
	if isGameover:
		return
	if current_block == null:
		return
	if Input.is_action_just_pressed("drop"):
		drop_block()
		current_block = null
		await get_tree().create_timer(CLICK_DDELAY).timeout
		current_block = next_block
		current_block.global_position = (left_marker.global_position + right_marker.global_position) / 2
		next_block = create_block(next_block_marker.global_position)
	if current_block.gravity_scale == 0:
		current_block.global_position.x = clamp(
			get_global_mouse_position().x,
			left_marker.global_position.x + current_block.size * 10,
			right_marker.global_position.x -  + current_block.size * 10
			)

func create_block(position):
	var block = block_scene.instantiate()
	block.disable_physics()
	block.global_position = position
	block.size = randi_range(1,4)
	add_child(block)
	return block

func drop_block():
	current_block.enable_physics()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	current_block = create_block((left_marker.global_position + right_marker.global_position) / 2)
	next_block = create_block(next_block_marker.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isGameover:
		return 
	for body in gameover_area.get_overlapping_bodies():
		if body.is_in_group("blocks"):
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
	
