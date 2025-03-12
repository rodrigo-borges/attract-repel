extends Resource
class_name CreatureData

static var MAX_ENERGY:float = 100.
static var BASE_REPRODUCTION_COST:float = 20.
static var MUTATION_CHANCE:float = .1
static var COLOR_MUTATION_STD:float = .1
static var ATTR_MUTATION_STD:float = .3
static var INTENSITY_MUTATION_STD:float = 1.
static var SENSE_RADIUS_MUTATION_STD:float = 10.
static var REPR_ENERGY_THR_MUTATION_STD:float = 5.
static var REPR_COOLDOWN_MUTATION_STD:float = 5.
static var BRAKE_MUTATION_STD:float = .2

var color:Color
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
var parent:CreatureData
var children:Array[CreatureData]
var vessel:CreatureVessel
var lifespan:float


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
	
func reproduce() -> CreatureData:
	var creature = CreatureData.create(
		color, size_radius,
		attraction, intensity, sense_radius,
		reproduction_energy_threshold, reproduction_cooldown,
		brake,)
	creature.mutate()
	creature.parent = self
	children.append(creature)
	return creature

func get_descendents() -> Array[CreatureData]:
	var descendents:Array[CreatureData] = children.duplicate()
	for c in children:
		descendents.append_array(c.get_descendents())
	return descendents

static func create(
		_color:Color, _size_radius:float,
		_attraction:Vector3, _intensity:float, _sense_radius:float,
		_reproduction_energy_threshold:float, _reproduction_cooldown:float,
		_brake:float,) -> CreatureData:
	var creature:CreatureData = CreatureData.new()
	creature.color = _color
	creature.size_radius = _size_radius
	creature.attraction = _attraction
	creature.intensity = _intensity
	creature.sense_radius = _sense_radius
	creature.reproduction_energy_threshold = _reproduction_energy_threshold
	creature.reproduction_cooldown = _reproduction_cooldown
	creature.brake = _brake
	creature.parent = null
	creature.children = []
	creature.lifespan = 0.
	return creature