extends Resource
class_name CreatureSpawnerData

@export var area:Rect2
@export var color_mean:Color = Color.DIM_GRAY
@export var color_std:float
@export var size_radius_mean:float = 10.
@export var size_radius_std:float
@export var sense_radius_mean:float = 100.
@export var sense_radius_std:float
@export var attraction_mean:Vector3
@export var attraction_std:float = .25
@export var intensity_mean:float = 5.
@export var intensity_std:float
@export var aggression_mean:Vector3
@export var aggression_std:float = .25
@export var aggression_intensity_mean:float = 5.
@export var aggression_intensity_std:float
@export var aggression_energy_threshold_mean:float = 50.
@export var aggression_energy_threshold_std:float
@export var reproduction_energy_threshold_mean:float = 50.
@export var reproduction_energy_threshold_std:float
@export var reproduction_cooldown_mean:float = 10.
@export var reproduction_cooldown_std:float
@export var brake_mean:float = .5
@export var brake_std:float
@export var incubation_time_mean:float = 5.
@export var incubation_time_std:float


func to_dict() -> Dictionary:
	var dict:Dictionary = {
		"area":Serializer.from_rect(area), "color_mean":Serializer.from_color(color_mean), "color_std":color_std,
		"size_radius_mean":size_radius_mean, "size_radius_std":size_radius_std,
		"sense_radius_mean":sense_radius_mean, "sense_radius_std":sense_radius_std,
		"attraction_mean":Serializer.from_vector3(attraction_mean), "attraction_std":attraction_std,
		"intensity_mean":intensity_mean, "intensity_std":intensity_std,
		"aggression_mean":Serializer.from_vector3(aggression_mean), "aggression_std":aggression_std,
		"aggression_intensity_mean":aggression_intensity_mean, "aggression_intensity_std":aggression_intensity_std,
		"aggression_energy_threshold_mean":aggression_energy_threshold_mean, "aggression_energy_threshold_std":aggression_energy_threshold_std,
		"reproduction_energy_threshold_mean":reproduction_energy_threshold_mean,
		"reproduction_energy_threshold_std":reproduction_energy_threshold_std,
		"reproduction_cooldown_mean":reproduction_cooldown_mean, "reproduction_cooldown_std":reproduction_cooldown_std,
		"brake_mean":brake_mean, "brake_std":brake_std,
		"incubation_time_mean":incubation_time_mean, "incubation_time_std":incubation_time_std}
	return dict

static func from_dict(dict:Dictionary) -> CreatureSpawnerData:
	var data = CreatureSpawnerData.create(
		Serializer.to_rect(dict["area"]), Serializer.to_color(dict["color_mean"]), dict["color_std"],
		dict["size_radius_mean"], dict["size_radius_std"], dict["sense_radius_mean"], dict["sense_radius_std"],
		Serializer.to_vector3(dict["attraction_mean"]), dict["attraction_std"],
		dict["intensity_mean"], dict["intensity_std"], Serializer.to_vector3(dict["aggression_mean"]), dict["aggression_std"],
		dict["aggression_intensity_mean"], dict["aggression_intensity_std"],
		dict["aggression_energy_threshold_mean"], dict["aggression_energy_threshold_std"],
		dict["reproduction_energy_threshold_mean"], dict["reproduction_energy_threshold_std"],
		dict["reproduction_cooldown_mean"], dict["reproduction_cooldown_std"],
		dict["brake_mean"], dict["brake_std"], dict["incubation_time_mean"], dict["incubation_time_std"])
	return data

static func create(
		_area:Rect2, _color_mean:Color, _color_std:float, _size_radius_mean:float, _size_radius_std:float,
		_sense_radius_mean:float, _sense_radius_std:float, _attraction_mean:Vector3, _attraction_std:float,
		_intensity_mean:float, _intensity_std:float, _aggression_mean:Vector3, _aggression_std:float,
		_aggression_intensity_mean:float, _aggression_intensity_std:float,
		_aggression_energy_threshold_mean:float, _aggression_energy_threshold_std:float,
		_reproduction_energy_threshold_mean:float, _reproduction_energy_threshold_std:float,
		_reproduction_cooldown_mean:float, _reproduction_cooldown_std:float, _brake_mean:float, _brake_std:float,
		_incubation_time_mean:float, _incubation_time_std:float) -> CreatureSpawnerData:
	var spawner = CreatureSpawnerData.new()
	spawner.area = _area
	spawner.color_mean = _color_mean
	spawner.color_std = _color_std
	spawner.size_radius_mean = _size_radius_mean
	spawner.size_radius_std = _size_radius_std
	spawner.sense_radius_mean = _sense_radius_mean
	spawner.sense_radius_std = _sense_radius_std
	spawner.attraction_mean = _attraction_mean
	spawner.attraction_std = _attraction_std
	spawner.intensity_mean = _intensity_mean
	spawner.intensity_std = _intensity_std
	spawner.aggression_mean = _aggression_mean
	spawner.aggression_std = _aggression_std
	spawner.aggression_intensity_mean = _aggression_intensity_mean
	spawner.aggression_intensity_std = _aggression_intensity_std
	spawner.aggression_energy_threshold_mean = _aggression_energy_threshold_mean
	spawner.aggression_energy_threshold_std = _aggression_energy_threshold_std
	spawner.reproduction_energy_threshold_mean = _reproduction_energy_threshold_mean
	spawner.reproduction_energy_threshold_std = _reproduction_energy_threshold_std
	spawner.reproduction_cooldown_mean = _reproduction_cooldown_mean
	spawner.reproduction_cooldown_std = _reproduction_cooldown_std
	spawner.brake_mean = _brake_mean
	spawner.brake_std = _brake_std
	spawner.incubation_time_mean = _incubation_time_mean
	spawner.incubation_time_std = _incubation_time_std
	return spawner
