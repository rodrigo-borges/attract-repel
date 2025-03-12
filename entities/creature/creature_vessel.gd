extends CharacterBody2D
class_name CreatureVessel

signal reproduced(child:CreatureVessel)
signal created_food(food:Food)
signal died

static var BASE_FORCE:float = 100.
static var BASE_MAINTENANCE_COST:float = 1.
static var BASE_MOVEMENT_COST:float = .1
static var FORCE_LINE_SCALE:float = 30.
static var FORCE_LINE_CAP:float = 50.

var data:CreatureData
var color:Color:
	get(): return data.color
var size_radius:float:
	get(): return data.size_radius
var attraction:Vector3:
	get(): return data.attraction
var intensity:float:
	get(): return data.intensity
var sense_radius:float:
	get(): return data.sense_radius
var reproduction_energy_threshold:float:
	get(): return data.reproduction_energy_threshold
var reproduction_cooldown:float:
	get(): return data.reproduction_cooldown
var brake:float:
	get(): return data.brake
var lifespan:float:
	get(): return data.lifespan
	set(value): data.lifespan = value
var children:int:
	get(): return data.children.size()

var energy:float
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
		if marker_sprite != null:
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
		if "color" in node and node != self:
			attraction_force += calculate_attraction_force(node)
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
			energy = minf(CreatureData.MAX_ENERGY, energy)
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

func calculate_attraction_force(node:Node2D) -> Vector2:
	var _force:Vector2 = (node.global_position - global_position).normalized() * BASE_FORCE * intensity
	_force *= attraction.x*node.color.r + attraction.y*node.color.g + attraction.z*node.color.b
	_force /= global_position.distance_squared_to(node.global_position) + 1.
	return _force

func reproduce() -> CreatureVessel:
	energy -= CreatureData.BASE_REPRODUCTION_COST
	on_reproduction_cooldown = true
	reproduction_cooldowm_timer.start(reproduction_cooldown)
	var child_data:CreatureData = data.reproduce()
	var child_vessel = CreatureVessel.create(child_data, energy/2.)
	child_vessel.marker = marker
	reproduced.emit(child_vessel)
	energy /= 2.
	return child_vessel

func die() -> void:
	var corpse:Food = Food.create(self.color, CreatureData.BASE_REPRODUCTION_COST, 60.)
	created_food.emit(corpse)
	died.emit()
	queue_free()

func update_marker() -> void:
	var new_texture:Texture2D = null if marker == null else marker.texture
	marker_sprite.set_texture(new_texture)
	marker_sprite.set_visible(marker!=null)

static func create(
		_data:CreatureData,
		_energy:float=CreatureData.MAX_ENERGY/2.) -> CreatureVessel:
	var creature:CreatureVessel = CreatureVessel.new()
	creature.data = _data
	creature.energy = _energy
	return creature
