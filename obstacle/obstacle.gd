extends StaticBody2D
class_name Obstacle

const scene_path:String = "res://obstacle/obstacle.tscn"

@export var data:ObstacleData:
    set(value): data = value; update()
@onready var shape:CollisionShape2D = find_child("Shape")


func _ready() -> void:
    shape.set_shape(RectangleShape2D.new())
    update()

func _draw() -> void:
    if data != null:
        var rect:Rect2 = Rect2(data.area)
        rect.position = -data.area.size/2.
        draw_rect(rect, Color.BLACK, false)
        draw_texture_rect(data.texture, rect, true, Color.BLACK)

func update() -> void:
    if data != null and shape != null:
        shape.shape.set_size(data.area.size)
        set_position(data.area.position + data.area.size/2.)
        queue_redraw()

static func create(_data:ObstacleData) -> Obstacle:
    var obstacle:Obstacle = load(scene_path).instantiate()
    obstacle.data = _data
    return obstacle