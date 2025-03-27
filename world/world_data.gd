extends Resource
class_name WorldData

@export var area:Rect2
@export var boundary_texture:Texture2D
@export var boundary_width:float
@export var creature_spawners:Array[CreatureSpawnerData]
@export var food_spawners:Array[FoodSpawnerData]
@export var obstacles:Array[ObstacleData]


func to_dict() -> Dictionary:
	var dict:Dictionary = {
		"area":Serializer.from_rect(area), "boundary_texture":Serializer.from_texture(boundary_texture),
		"boundary_width":boundary_width, "creature_spawners":Serializer.from_list(creature_spawners),
		"food_spawners":Serializer.from_list(food_spawners), "obstacles":Serializer.from_list(obstacles)}
	return dict

static func from_dict(dict:Dictionary) -> WorldData:
	var _creature_spawners:Array[CreatureSpawnerData] = []
	for c in dict["creature_spawners"]:
		_creature_spawners.append(CreatureSpawnerData.from_dict(c))
	var _food_spawners:Array[FoodSpawnerData] = []
	for f in dict["food_spawners"]:
		_food_spawners.append(FoodSpawnerData.from_dict(f))
	var _obstacles:Array[ObstacleData] = []
	for o in dict["obstacles"]:
		_obstacles.append(ObstacleData.from_dict(o))
	var data = WorldData.create(
		Serializer.to_rect(dict["area"]), Serializer.to_texture(dict["boundary_texture"]),
		dict["boundary_width"], _creature_spawners, _food_spawners, _obstacles)
	return data

static func create(
		_area:Rect2, _boundary_texture:Texture2D, _boundary_width:float,
		_creature_spawners:Array[CreatureSpawnerData], _food_spawners:Array[FoodSpawnerData],
		_obstacles:Array[ObstacleData]) -> WorldData:
	var data = WorldData.new()
	data.area = _area
	data.boundary_texture = _boundary_texture
	data.boundary_width = _boundary_width
	data.creature_spawners = _creature_spawners
	data.food_spawners = _food_spawners
	data.obstacles = _obstacles
	return data
