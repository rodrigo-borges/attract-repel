extends Resource
class_name FoodSpawnerData

@export var area:Rect2
@export var spawn_rate:float
@export var color:Color
@export var color_std:float
@export var energy_provided:float
@export var decay_time:float


func to_dict() -> Dictionary:
	var dict:Dictionary = {
		"area": Serializer.from_rect(area),
		"spawn_rate": spawn_rate,
		"color": Serializer.from_color(color),
		"color_std": color_std,
		"energy_provided": energy_provided,
		"decay_time": decay_time}
	return dict

static func from_dict(dict:Dictionary) -> FoodSpawnerData:
	var data = FoodSpawnerData.create(
		Serializer.to_rect(dict["area"]), dict["spawn_rate"], Serializer.to_color(dict["color"]),
		dict["color_std"], dict["energy_provided"], dict["decay_time"])
	return data

static func create(
		_area:Rect2, _spawn_rate:float, _color:Color, _color_std:float,
		_energy_provided:float, _decay_time:float) -> FoodSpawnerData:
	var spawner = FoodSpawnerData.new()
	spawner.area = _area
	spawner.spawn_rate = _spawn_rate
	spawner.color = _color
	spawner.energy_provided = _energy_provided
	spawner.decay_time = _decay_time
	return spawner