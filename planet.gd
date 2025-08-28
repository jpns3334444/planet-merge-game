extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var gravity_field: Area2D = $GravityField
@onready var gravity_shape: CollisionShape2D = $GravityField/GravityShape

var planet_scene := preload("res://planet.tscn")

var max_size = 10
var size = 1
var bodies_in_gravity_field = []
var gravity_strength: float:
	get:
		return size * 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape_2d.shape.radius = size * 10
	gravity_shape.shape.radius = size * 30
	body_entered.connect(handle_collision)
	gravity_field.body_entered.connect(_on_gravity_body_entered)
	gravity_field.body_exited.connect(_on_gravity_body_exited)

func _on_gravity_body_entered(body):
	if body != self and body.is_in_group("planets"):
		bodies_in_gravity_field.append(body)

func _on_gravity_body_exited(body):
	bodies_in_gravity_field.erase(body)

func _physics_process(delta):
	for body in bodies_in_gravity_field:
		if is_instance_valid(body):
			if body.size < size:
				var direction = global_position - body.global_position
				var distance = direction.length()
				
				if distance > 20:
					var force_magnitude = (gravity_strength * body.mass) / (distance * distance)
					var force = direction.normalized() * force_magnitude * 5000
					
					body.apply_central_force(force)
			


func _draw():
	var color = Color.from_hsv(float(size % max_size) / max_size, 1,1)
	draw_circle(Vector2.ZERO,collision_shape_2d.shape.radius,color)

func handle_collision(body):
	if is_queued_for_deletion():
		return 
	if not body.is_in_group("planets"):
		return
	if body.size != size:
		return
		
	body.queue_free()
	queue_free()
	
	var planet = planet_scene.instantiate()
	planet.global_position = (global_position + body.global_position) / 2
	planet.size = size + 1
	get_parent().add_child.call_deferred(planet)
	
	Gamemaster.planet_removed.emit(size)

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
