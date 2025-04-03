extends CharacterBody2D
class_name CreatureVessel

signal reproduced(child:CreatureVessel)
signal created_food(food:Food)
signal died

static var BASE_FORCE:float = 10000.1
static var BASE_MAINTENANCE_COST:float = 1.
static var BASE_MOVEMENT_COST:float = .001
static var BASE_ATTACK_COST:float = 1.
static var BASE_ATTACK_DAMAGE:float = 2.
static var BASE_SENSE_COST:float = .001
static var BASE_REPRODUCTION_COST:float = 20.
static var FORCE_LINE_SCALE:float = .1
static var FORCE_LINE_CAP:float = 50.

static var coll_layer:int = 0b0001
static var coll_mask:int = 0b0110
static var sense_mask:int = 0b0011

var data:CreatureData
var color:Color:
	get(): return data.color
var size_radius:float:
	get(): return data.size_radius
var mass:float:
	get(): return data.mass
var attraction:Vector3:
	get(): return data.attraction
var intensity:float:
	get(): return data.intensity
var aggression:Vector3:
	get(): return data.aggression
var aggression_intensity:float:
	get(): return data.aggression_intensity
var aggression_energy_threshold:float:
	get(): return data.aggression_energy_threshold
var sense_radius:float:
	get(): return data.sense_radius
var reproduction_energy_threshold:float:
	get(): return data.reproduction_energy_threshold
var reproduction_cooldown:float:
	get(): return data.reproduction_cooldown
var brake:float:
	get(): return data.brake
var incubation_time:float:
	get(): return data.incubation_time
var lifespan:float:
	get(): return data.lifespan
	set(value): data.lifespan = value

var alive:bool
var energy:float
var on_reproduction_cooldown:bool
var attraction_force:Vector2
var brake_force:Vector2
var total_force:Vector2
var sense_area:Area2D
var reproduction_cooldowm_timer:Timer
var attraction_line:Line2D
var brake_line:Line2D
var incubation_timer:Timer
var on_incubation:bool
var blink_tween:Tween
var marker_sprite:Sprite2D
var draw_force_lines:bool = false
var draw_sense_radius:bool = false
var attack_ray:ColoredRay
var sensed_nodes:Array[Node2D]
var sense_rays:Array[RayCast2D]


func _ready() -> void:
	self.set_motion_mode(MotionMode.MOTION_MODE_FLOATING)
	self.set_pickable(true)
	self.set_collision_layer(0b0001)
	self.set_collision_mask(0b0010)
	var coll_shape = CollisionShape2D.new()
	var coll_circle = CircleShape2D.new()
	coll_circle.set_radius(self.size_radius)
	coll_shape.set_shape(coll_circle)
	add_child(coll_shape)

	sense_area = Area2D.new()
	sense_area.set_collision_mask(0b0011)
	var area_shape = CollisionShape2D.new()
	var area_circle = CircleShape2D.new()
	area_circle.set_radius(self.sense_radius)
	area_shape.set_shape(area_circle)
	sense_area.add_child(area_shape)
	add_child(sense_area)

	reproduction_cooldowm_timer = Timer.new()
	reproduction_cooldowm_timer.set_one_shot(true)
	reproduction_cooldowm_timer.timeout.connect(leave_reproduction_cooldown)
	add_child(reproduction_cooldowm_timer)

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

	incubation_timer = Timer.new()
	incubation_timer.set_one_shot(true)
	incubation_timer.timeout.connect(leave_incubation)
	add_child(incubation_timer)
	enter_incubation()
	incubation_timer.start(incubation_time)

	marker_sprite = Sprite2D.new()
	add_child(marker_sprite)
	marker_sprite.set_scale(Vector2(.75, .75))
	update_marker()

	attack_ray = ColoredRay.create()
	add_child(attack_ray)
	attack_ray.set_z_index(-1)
	attack_ray.color = color

func _process(_delta:float) -> void:
	if draw_force_lines:
		update_force_line(attraction_line, attraction_force)
		update_force_line(brake_line, brake_force)

func _physics_process(delta: float) -> void:
	if Engine.time_scale <= 0. or on_incubation:
		return

	lifespan += delta

	if not on_reproduction_cooldown and energy >= reproduction_energy_threshold:
		reproduce()

	attraction_force = Vector2.ZERO
	var nodes_in_sight:Array[Node2D] = sense_area.get_overlapping_bodies()
	for node in nodes_in_sight:
		if node != self and "color" in node:
			if node in sensed_nodes:
				var idx:int = sensed_nodes.find(node)
				sense_rays[idx].set_target_position(to_local(node.global_position))
				if !sense_rays[idx].is_colliding():
					attraction_force += calculate_attraction_force(node)
			else:
				var ray = RayCast2D.new()
				add_child(ray)
				ray.set_collision_mask(0b0100)
				ray.set_target_position(to_local(node.global_position))
				sensed_nodes.append(node)
				sense_rays.append(ray)
	for i in range(sensed_nodes.size()-1, -1, -1):
		if !is_instance_valid(sensed_nodes[i]) or sensed_nodes[i] not in nodes_in_sight:
			sensed_nodes.pop_at(i)
			var ray:RayCast2D = sense_rays.pop_at(i)
			ray.queue_free()
	if sense_rays.size() != sensed_nodes.size():
		print("Difference: %d" % (sense_rays.size()-sensed_nodes.size()))

	brake_force = -velocity * delta * brake * mass
	total_force = attraction_force + brake_force
	velocity += total_force / data.mass
	
	var aggr_target:CreatureVessel = null
	var max_aggr:float = 0.
	if energy > aggression_energy_threshold:
		for node in nodes_in_sight:
			if node != self and node is CreatureVessel:
				var idx:int = sensed_nodes.find(node)
				if !sense_rays[idx].is_colliding():
					var vessel = node as CreatureVessel
					var _aggr:float = calculate_aggression(vessel)
					if _aggr > max_aggr:
						max_aggr = _aggr
						aggr_target = vessel
	if is_instance_valid(aggr_target):
		attack_ray.aim_at(aggr_target)
		aggr_target.drain_energy(max_aggr * BASE_ATTACK_DAMAGE * delta)
		drain_energy(max_aggr * BASE_ATTACK_COST * delta)
	else:
		attack_ray.stop_aiming()

	drain_energy(BASE_MAINTENANCE_COST * delta)
	drain_energy(total_force.length() * delta * BASE_MOVEMENT_COST)
	drain_energy(sense_radius * delta * BASE_SENSE_COST)
	
	var collision:KinematicCollision2D = move_and_collide(velocity*delta)
	if collision != null:
		if collision.get_collider() is Food:
			var food = collision.get_collider() as Food
			energy += food.energy_provided
			energy = minf(data.max_energy, energy)
			food.consume()
		else:
			velocity = velocity.bounce(collision.get_normal())

func _draw() -> void:
	if draw_sense_radius:
		draw_circle(Vector2.ZERO, self.sense_radius, Color(0., 0., 0., 0.1))
	draw_circle(Vector2.ZERO, self.size_radius, self.color)
	draw_circle(Vector2.ZERO, self.size_radius, Color.BLACK, false)

func enter_incubation() -> void:
	self.set_collision_layer(0b1000)
	self.set_collision_mask(0b0000)
	set_modulate(Color(1.,1.,1.,.5))
	sense_area.set_collision_mask(0b0000)
	sense_area.set_monitoring(false)
	blink_tween = create_tween().set_loops()
	blink_tween.tween_property(self, "modulate", Color(1.,1.,1.,.1), .5)
	blink_tween.tween_property(self, "modulate", Color(1.,1.,1.,.5), .5)
	on_incubation = true

func leave_incubation() -> void:
	self.set_collision_layer(coll_layer)
	self.set_collision_mask(coll_mask)
	sense_area.set_collision_mask(sense_mask)
	sense_area.set_monitoring(true)
	blink_tween.kill()
	set_modulate(Color.WHITE)
	enter_reproduction_cooldown()
	alive = true
	on_incubation = false

func enter_reproduction_cooldown() -> void:
	on_reproduction_cooldown = true
	reproduction_cooldowm_timer.start(reproduction_cooldown)

func leave_reproduction_cooldown() -> void:
	on_reproduction_cooldown = false

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

func calculate_aggression(node:Node2D) -> float:
	var _aggr:float = aggression.x*node.color.r + aggression.y*node.color.g + aggression.z*node.color.b
	_aggr *= aggression_intensity
	return _aggr

func reproduce() -> CreatureVessel:
	energy -= BASE_REPRODUCTION_COST
	on_reproduction_cooldown = true
	reproduction_cooldowm_timer.start(reproduction_cooldown)
	var child_data:CreatureData = data.reproduce()
	var child_vessel = CreatureVessel.create(child_data, energy/2.)
	reproduced.emit(child_vessel)
	energy /= 2.
	return child_vessel

func drain_energy(amount:float) -> void:
	energy -= amount
	if energy <= 0.:
		die()

func die() -> void:
	if alive:
		var corpse:Food = Food.create(self.color, BASE_REPRODUCTION_COST, 60.)
		created_food.emit(corpse)
		data.vessel = null
		died.emit()
		queue_free()
		alive = false

func update_marker() -> void:
	var new_texture:Texture2D = null if data.marker == null else data.marker.texture
	marker_sprite.set_texture(new_texture)
	marker_sprite.set_visible(data.marker!=null)

func toggle_draw_los(toggled_on:bool) -> void:
	if toggled_on != draw_sense_radius:
		draw_sense_radius = toggled_on
		queue_redraw()

func toggle_draw_lines(toggled_on:bool) -> void:
	draw_force_lines = toggled_on
	brake_line.set_visible(toggled_on)
	attraction_line.set_visible(toggled_on)

func toggle_details(toggled_on:bool) -> void:
	toggle_draw_los(toggled_on)
	toggle_draw_lines(toggled_on)

func get_parent_vessel() -> CreatureVessel:
	var parent:CreatureVessel = null
	if data.parent != null and data.parent.vessel != null:
		parent = data.parent.vessel
	return parent

func get_descendents_vessels() -> Array[CreatureVessel]:
	var descendents:Array[CreatureData] = data.get_descendents()
	var vessels:Array[CreatureVessel] = []
	for d in descendents:
		if d.vessel != null:
			vessels.append(d.vessel)
	return vessels

static func create(
		_data:CreatureData,
		_energy:float=-1.) -> CreatureVessel:
	var creature:CreatureVessel = CreatureVessel.new()
	creature.data = _data
	if _energy < 0.:
		_energy = _data.max_energy/2.
	creature.energy = _energy
	_data.vessel = creature
	return creature
