extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var block_scene := preload("res://block.tscn")

var max_size = 10
var size = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape_2d.shape.radius = size * 10
	body_entered.connect(handle_collision)


func _draw():
	var color = Color.from_hsv(float(size % max_size) / max_size, 1,1)
	draw_circle(Vector2.ZERO,collision_shape_2d.shape.radius,color)

func handle_collision(body):
	if is_queued_for_deletion():
		return 
	if not body.is_in_group("blocks"):
		return
	if body.size != size:
		return
		
	body.queue_free()
	queue_free()
	
	var block = block_scene.instantiate()
	block.global_position = (global_position + body.global_position) / 2
	block.size = size + 1
	get_parent().add_child.call_deferred(block)
	
	Gamemaster.block_removed.emit(size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func disable_physics():
	collision_layer = 0
	gravity_scale = 0
	collision_mask = 0

func enable_physics():
	collision_layer = 1
	gravity_scale = 1
	collision_mask = 1
