extends RayCast2D
class_name ColoredRay

static var scene_path:String = "res://colored_ray/colored_ray.tscn"

@onready var line:Line2D = find_child("Line")
@onready var hit_particles:CPUParticles2D = find_child("HitParticles")
@onready var animation_player:AnimationPlayer = find_child("AnimationPlayer")
@export var color:Color = Color("#ffffff"):
	set(value):
		color = value
		if line != null:
			_update_line()
		if hit_particles != null:
			_update_particles()
@export var width:float = 3.:
	set(value):
		width = value
		if line != null:
			_update_line()
var target:CollisionObject2D


func _ready() -> void:
	line.set_points([Vector2.ZERO, Vector2.ZERO])
	_update_line()
	_update_particles()

func _process(_delta:float) -> void:
	if enabled and is_colliding() and get_collider() == target:
		line.set_visible(true)
		line.set_point_position(1, to_local(get_collision_point()))
		hit_particles.set_emitting(true)
		hit_particles.set_global_position(get_collision_point())
		hit_particles.set_global_rotation(get_collision_normal().angle())
	else:
		line.set_visible(false)
		hit_particles.set_emitting(false)

func _physics_process(_delta:float) -> void:
	if enabled:
		if is_colliding() and target != null and get_collider() != target:
			add_exception(get_collider())
			set_visible(false)
		elif is_colliding() and get_collider() == target:
			set_visible(true)
		if target != null:
			set_target_position(to_local(target.global_position))

func aim_at(_target:CollisionObject2D) -> void:
	if _target != target:
		clear_exceptions()
		animation_player.play("lightning")
		enabled = true
		target = _target

func stop_aiming() -> void:
	set_target_position(Vector2.ZERO)
	animation_player.stop()
	enabled = false
	target = null

func _update_line() -> void:
	line.set_width(width)
	line.set_default_color(color)

func _update_particles() -> void:
	hit_particles.set_color(color)

static func create() -> ColoredRay:
	var ray:ColoredRay = load(scene_path).instantiate()
	return ray