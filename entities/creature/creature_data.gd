extends Resource
class_name CreatureData

static var MUTATION_CHANCE:float = .1
static var COLOR_MUTATION_STD:float = .1
static var RADIUS_MUTATION_STD:float = 1.
static var ATTR_MUTATION_STD:float = .3
static var INTENSITY_MUTATION_STD:float = 1.
static var SENSE_RADIUS_MUTATION_STD:float = 10.
static var REPR_ENERGY_THR_MUTATION_STD:float = 5.
static var REPR_COOLDOWN_MUTATION_STD:float = 5.
static var BRAKE_MUTATION_STD:float = .2
static var INCUBATION_MUTATION_STD:float = 1.

static var MASS_DENSITY:float = 1.
static var ENERGY_DENSITY:float = 2.

var color:Color:
	set(value):
		color = value
		color_vec = Vector3(value.r, value.g, value.b)
var color_vec:Vector3
var size_radius:float:
	set(value):
		size_radius = maxf(value, 1.)
		mass = PI*size_radius*size_radius*MASS_DENSITY
		max_energy = 2*PI*size_radius*ENERGY_DENSITY
var mass:float
var max_energy:float
var attraction:Vector3
var intensity:float:
	set(value): intensity = maxf(value, 1.)
var sense_radius:float:
	set(value): sense_radius = maxf(value, 50.)
var reproduction_energy_threshold:float:
	set(value): reproduction_energy_threshold = clampf(value, 0., max_energy)
var reproduction_cooldown:float:
	set(value): reproduction_cooldown = maxf(value, 0.)
var brake:float:
	set(value): brake = clampf(value, 0., 1.)
var incubation_time:float:
	set(value): incubation_time = maxf(value, 0.)
var generation:int
var parent:CreatureData
var children:Array[CreatureData]
var vessel:CreatureVessel
var lifespan:float
var marker:Marker


func mutate() -> void:
	if randf() < MUTATION_CHANCE:
		color.r = clampf(color.r + randfn(0., COLOR_MUTATION_STD), 0., 1.)
	if randf() < MUTATION_CHANCE:
		color.g = clampf(color.r + randfn(0., COLOR_MUTATION_STD), 0., 1.)
	if randf() < MUTATION_CHANCE:
		color.b = clampf(color.r + randfn(0., COLOR_MUTATION_STD), 0., 1.)
	if randf() < MUTATION_CHANCE:
		size_radius += randfn(0., RADIUS_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		attraction.x += randfn(0., ATTR_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		attraction.y += randfn(0., ATTR_MUTATION_STD)
	if randf() < MUTATION_CHANCE:
		attraction.z += randfn(0., ATTR_MUTATION_STD)
	attraction = attraction.normalized()
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
	if randf() < MUTATION_CHANCE:
		incubation_time += randfn(0., INCUBATION_MUTATION_STD)
	
func reproduce() -> CreatureData:
	var creature = CreatureData.create(
		color, size_radius,
		attraction, intensity, sense_radius,
		reproduction_energy_threshold, reproduction_cooldown,
		brake, incubation_time)
	creature.generation = generation + 1
	creature.parent = self
	creature.marker = marker
	creature.mutate()
	children.append(creature)
	return creature

func get_descendents() -> Array[CreatureData]:
	var descendents:Array[CreatureData] = children.duplicate()
	for c in children:
		descendents.append_array(c.get_descendents())
	return descendents

func get_descendents_stats() -> Array[int]:
	var total:int = 0
	var alive:int = 0
	var descendents:Array[CreatureData] = get_descendents()
	for d in descendents:
		total += 1
		if d.vessel != null:
			alive += 1
	return [total, alive]

static func create(
		_color:Color, _size_radius:float,
		_attraction:Vector3, _intensity:float, _sense_radius:float,
		_reproduction_energy_threshold:float, _reproduction_cooldown:float,
		_brake:float, _incubation_time:float) -> CreatureData:
	var creature:CreatureData = CreatureData.new()
	creature.color = _color
	creature.size_radius = _size_radius
	creature.attraction = _attraction
	creature.intensity = _intensity
	creature.sense_radius = _sense_radius
	creature.reproduction_energy_threshold = _reproduction_energy_threshold
	creature.reproduction_cooldown = _reproduction_cooldown
	creature.brake = _brake
	creature.incubation_time = _incubation_time
	creature.generation = 0
	creature.parent = null
	creature.children = []
	creature.lifespan = 0.
	creature.marker = null
	return creature