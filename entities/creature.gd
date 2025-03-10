extends ColoredEntity
class_name Creature

signal reproduced(child:Creature)
signal created_food(food:Food)
signal died

const BASE_FORCE:float = 100.
const MAX_ENERGY:float = 100.
const BASE_MAINTENANCE_COST:float = 1.
const BASE_MOVEMENT_COST:float = .1
const BASE_REPRODUCTION_COST:float = 20.
const MUTATION_CHANCE:float = .1
const COLOR_MUTATION_STD:float = .1
const ATTR_MUTATION_STD:float = .3
const INTENSITY_MUTATION_STD:float = 1.
const SENSE_RADIUS_MUTATION_STD:float = 10.
const REPR_ENERGY_THR_MUTATION_STD:float = 5.
const REPR_COOLDOWN_MUTATION_STD:float = 5.
const BRAKE_MUTATION_STD:float = .2
const FORCE_LINE_SCALE:float = 30.
const FORCE_LINE_CAP:float = 50.

var size_radius:float:
	set(value): size_radius = maxf(value, 1.)
var attraction:Vector3
var intensity:float:
	set(value): intensity = maxf(value, 1.)
var sense_radius:float:
	set(value): sense_radius = maxf(value, 50.)
var reproduction_energy_threshold:float:
	set(value): reproduction_energy_threshold = clampf(value, 0., MAX_ENERGY)
var reproduction_cooldown:float:
	set(value): reproduction_cooldown = maxf(value, 0.)
var brake:float:
	set(value): brake = clampf(value, 0., 1.)
var energy:float
var lifespan:float
var children:int
var on_reproduction_cooldown:bool
var attraction_force:Vector2
var brake_force:Vector2
var total_force:Vector2
var sense_area:Area2D
var reproduction_cooldowm_timer:Timer
var attraction_line:Line2D
var brake_line:Line2D
var marker:Marker:
	set(value):
		marker = value
		if marker != null and marker_sprite != null:
			update_marker()
var marker_sprite:Sprite2D


func _ready() -> void:
	self.set_pickable(true)
	self.set_collision_layer(0b0001)
	self.set_collision_mask(0b0010)
	var coll_shape = CollisionShape2D.new()
	var coll_circle = CircleShape2D.new()
	coll_circle.set_radius(self.size_radius)
	coll_shape.set_shape(coll_circle)
	add_child(coll_shape)

	sense_area = Area2D.new()
	sense_area.set_collision_layer(0b0000)
	sense_area.set_collision_mask(0b0011)
	var area_shape = CollisionShape2D.new()
	var area_circle = CircleShape2D.new()
	area_circle.set_radius(self.sense_radius)
	area_shape.set_shape(area_circle)
	sense_area.add_child(area_shape)
	add_child(sense_area)

	reproduction_cooldowm_timer = Timer.new()
	reproduction_cooldowm_timer.set_one_shot(true)
	reproduction_cooldowm_timer.timeout.connect(
		func(): on_reproduction_cooldown = false)
	add_child(reproduction_cooldowm_timer)
	on_reproduction_cooldown = true
	reproduction_cooldowm_timer.start(reproduction_cooldown)

	attraction_line = Line2D.new()
	add_child(attraction_line)
	attraction_line.set_width(2.)
	attraction_line.add_point(Vector2.ZERO)
	attraction_line.add_point(Vector2.ZERO)

	brake_line = Line2D.new()
	add_child(brake_line)
	brake_line.set_width(2.)
	brake_line.add_point(Vector2.ZERO)
	brake_line.add_point(Vector2.ZERO)

	marker_sprite = Sprite2D.new()
	add_child(marker_sprite)
	marker_sprite.set_scale(Vector2(.5, .5))
	update_marker()

func _process(_delta:float) -> void:
	update_force_line(attraction_line, attraction_force)
	update_force_line(brake_line, brake_force)

func _physics_process(delta: float) -> void:
	if Engine.time_scale <= 0.:
		return

	lifespan += delta

	if not on_reproduction_cooldown and energy >= reproduction_energy_threshold:
		reproduce()

	attraction_force = Vector2.ZERO
	var nodes_in_sight:Array[Node2D] = sense_area.get_overlapping_bodies()
	for node in nodes_in_sight:
		if node is ColoredEntity and node != self:
			var entity = node as ColoredEntity
			attraction_force += calculate_attraction_force(entity)
	brake_force = -velocity * delta * brake
	total_force = attraction_force + brake_force
	velocity += total_force
	if global_position.x - size_radius < World.area.position.x:
		velocity.x = abs(velocity.x)
	elif global_position.x + size_radius > World.area.end.x:
		velocity.x = -abs(velocity.x)
	if global_position.y - size_radius < World.area.position.y:
		velocity.y = abs(velocity.y)
	elif global_position.y +size_radius > World.area.end.y:
		velocity.y = -abs(velocity.y)

	energy -= total_force.length() * delta * BASE_MOVEMENT_COST
	energy -= BASE_MAINTENANCE_COST * delta
	if energy <= 0.:
		die()
	
	var collision:KinematicCollision2D = move_and_collide(velocity*delta)
	if collision != null:
		if collision.get_collider() is Food:
			var food = collision.get_collider() as Food
			energy += food.energy_provided
			energy = minf(MAX_ENERGY, energy)
			food.consume()

func _draw() -> void:
	draw_circle(Vector2.ZERO, self.size_radius, self.color)
	draw_circle(Vector2.ZERO, self.size_radius, Color.BLACK, false)
	draw_circle(Vector2.ZERO, self.sense_radius, Color(0., 0., 0., 0.3), false)

func update_force_line(line:Line2D, force:Vector2) -> void:
	var line_length:float = min(force.length()*FORCE_LINE_SCALE, FORCE_LINE_CAP)
	if line_length >= FORCE_LINE_CAP:
		line.set_modulate(Color.RED)
	else:
		line.set_modulate(Color.WHITE)
	line.set_point_position(1, force.normalized()*line_length)

func calculate_attraction_force(entity:ColoredEntity) -> Vector2:
	var _force:Vector2 = (entity.global_position - global_position).normalized() * BASE_FORCE * intensity
	_force *= attraction.x*entity.color.r + attraction.y*entity.color.g + attraction.z*entity.color.b
	_force /= global_position.distance_squared_to(entity.global_position) + 1.
	return _force

func mutate() -> void:
	if randf() < MUTATION_CHANCE:
		color.r = clampf(color.r + randfn(0., COLOR_MUTATION_STD), 0., 1.)
	if randf() < MUTATION_CHANCE:
		color.g = clampf(color.r + randfn(0., COLOR_MUTATION_STD), 0., 1.)
	if randf() < MUTATION_CHANCE:
		color.b = clampf(color.r + randfn(0., COLOR_MUTATION_STD), 0., 1.)
	if randf() < MUTATION_CHANCE:
		attraction.x += randfn(0., ATTR_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		attraction.y += randfn(0., ATTR_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		attraction.z += randfn(0., ATTR_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		intensity += randfn(0., INTENSITY_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		sense_radius += randfn(0., SENSE_RADIUS_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		reproduction_energy_threshold += randfn(0., REPR_ENERGY_THR_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		reproduction_cooldown += randfn(0., REPR_COOLDOWN_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		brake += randfn(0., BRAKE_MUTATION_STD)

	attraction = attraction.normalized()

func reproduce() -> Creature:
	energy -= BASE_REPRODUCTION_COST
	on_reproduction_cooldown = true
	reproduction_cooldowm_timer.start(reproduction_cooldown)
	var creature = Creature.create(
		color, size_radius,
		attraction, intensity, sense_radius,
		reproduction_energy_threshold, reproduction_cooldown,
		brake,
		energy/2.)
	creature.marker = marker
	creature.mutate()
	reproduced.emit(creature)
	energy /= 2.
	children += 1
	return creature

func die() -> void:
	var corpse:Food = Food.create(self.color, BASE_REPRODUCTION_COST, 60.)
	created_food.emit(corpse)
	died.emit()
	queue_free()

func update_marker() -> void:
	var new_texture:Texture2D = null if marker == null else marker.texture
	marker_sprite.set_texture(new_texture)
	marker_sprite.set_visible(marker!=null)

static func create(
		_color:Color, _size_radius:float,
		_attraction:Vector3, _intensity:float, _sense_radius:float,
		_reproduction_energy_threshold:float, _reproduction_cooldown:float,
		_brake:float,
		_energy:float=MAX_ENERGY/2.) -> Creature:
	var creature:Creature = Creature.new()
	creature.color = _color
	creature.size_radius = _size_radius
	creature.attraction = _attraction
	creature.intensity = _intensity
	creature.sense_radius = _sense_radius
	creature.reproduction_energy_threshold = _reproduction_energy_threshold
	creature.reproduction_cooldown = _reproduction_cooldown
	creature.brake = _brake
	creature.energy = _energy
	creature.lifespan = 0.
	creature.children = 0
	return creature
