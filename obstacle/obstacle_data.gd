extends Resource
class_name ObstacleData

@export var area:Rect2
@export var texture:Texture2D


func to_dict() -> Dictionary:
	var dict:Dictionary = {
		"area": Serializer.from_rect(area),
		"texture_path": Serializer.from_texture(texture)}
	return dict

static func from_dict(dict:Dictionary) -> ObstacleData:
	var data = ObstacleData.create(
		Serializer.to_rect(dict["area"]),
		Serializer.to_texture(dict["texture_path"]))
	return data

static func create(_area:Rect2, _texture:Texture2D) -> ObstacleData:
	var obstacle = ObstacleData.new()
	obstacle.area = _area
	obstacle.texture = _texture
	return obstacle
