extends Control
class_name WorldPreview

@export var data:WorldData
var preview_scale:float
var preview_translation:Vector2


func _ready() -> void:
    update()

func _draw() -> void:
    if data != null:
        draw_boundaries()
        for c_s in data.creature_spawners:
            draw_creature_spawner(c_s)
        for f_s in data.food_spawners:
            draw_food_spawner(f_s)
        for o in data.obstacles:
            draw_obstacle(o)

func set_data(_data:WorldData) -> void:
    data = _data
    update()

func update() -> void:
    if data != null:
        preview_scale = 1./max(data.area.size.x/size.x, data.area.size.y/size.y)
        var spare_width:float = size.x - data.area.size.x * preview_scale
        var spare_height:float = size.y - data.area.size.y * preview_scale
        preview_translation = Vector2(spare_width/2., spare_height/2.)
        queue_redraw()

func adjust_rect(rect:Rect2) -> Rect2:
    var new = Rect2(rect)
    new.size *= preview_scale
    new.position = adjust_vec(new.position)
    return new

func adjust_vec(vec:Vector2) -> Vector2:
    var new = Vector2(vec)
    new *= preview_scale
    new += preview_translation
    return new

func draw_boundaries() -> void:
    draw_rect(adjust_rect(data.area), Color.WHITE, false)

func draw_creature_spawner(_data:CreatureSpawnerData) -> void:
    var x0:float = _data.area.position.x
    var y0:float = _data.area.position.y
    var x1:float = _data.area.end.x
    var y1:float = _data.area.end.y
    var dash_length:float = 10.
    draw_dashed_line(adjust_vec(Vector2(x0, y0)), adjust_vec(Vector2(x1, y0)), _data.color_mean, -1., dash_length)
    draw_dashed_line(adjust_vec(Vector2(x1, y0)), adjust_vec(Vector2(x1, y1)), _data.color_mean, -1., dash_length)
    draw_dashed_line(adjust_vec(Vector2(x1, y1)), adjust_vec(Vector2(x0, y1)), _data.color_mean, -1., dash_length)
    draw_dashed_line(adjust_vec(Vector2(x0, y1)), adjust_vec(Vector2(x0, y0)), _data.color_mean, -1., dash_length)

func draw_food_spawner(_data:FoodSpawnerData) -> void:
    draw_rect(adjust_rect(_data.area), _data.color*Color(1.,1.,1.,.05))
    draw_rect(adjust_rect(_data.area), _data.color, false)

func draw_obstacle(_data:ObstacleData) -> void:
    draw_rect(adjust_rect(_data.area), Color.WHITE)