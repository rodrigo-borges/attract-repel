extends Resource
class_name ObstacleData

@export var area:Rect2
@export var texture:Texture2D


static func create(_area:Rect2, _texture:Texture2D) -> ObstacleData:
    var obstacle = ObstacleData.new()
    obstacle.area = _area
    obstacle.texture = _texture
    return obstacle