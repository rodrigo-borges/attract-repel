extends Control
class_name MiniMap

@onready var map:MapView = find_child("MapView")
@export var world:World
@export var camera:Camera2D


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	if world != null and camera != null:
		var map_scale:float = max(world.data.area.size.x/map.size.x, world.data.area.size.y/map.size.y)
		var world_rect:Rect2 = Rect2(world.data.area)
		world_rect.size /= map_scale
		var camera_rect:Rect2 = camera.get_viewport_rect()
		camera_rect.size.x /= camera.zoom.x
		camera_rect.size.y /= camera.zoom.y
		camera_rect.position += camera.global_position - camera_rect.size/2.
		camera_rect.position /= map_scale
		camera_rect.size /= map_scale

		var obstacle_rects:Array[Rect2] = []
		for o in world.data.obstacles:
			var rect = Rect2(o.area)
			rect.size /= map_scale
			rect.position /= map_scale
			obstacle_rects.append(rect)

		var points:PackedVector2Array = PackedVector2Array()
		for c in world.creatures:
			points.append(c.global_position/map_scale)

		map.world_rect = world_rect
		map.camera_rect = camera_rect
		map.obstacle_rects = obstacle_rects
		map.creatures = points
		map.queue_redraw()
