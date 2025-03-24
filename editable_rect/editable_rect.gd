extends Node2D
class_name EditableRect

static var scene_path:String = "res://editable_rect/editable_rect.tscn"

signal started_editing()
signal rect_updated()

@export var rect:Rect2
@export var color:Color
@export var camera_zoom:Vector2 = Vector2.ONE
@onready var handles:Dictionary[String, CollisionObject2D] = {
    "NW":find_child("HandleNW"), "NE":find_child("HandleNE"),
    "SE":find_child("HandleSE"), "SW":find_child("HandleSW")}
@onready var dragger:CollisionObject2D = find_child("Dragger")
var hovered_element:CollisionObject2D
var selected_element:CollisionObject2D
var scaling:bool
var x_affected:CollisionObject2D
var y_affected:CollisionObject2D
var dragging:bool
var previous_mouse_position:Vector2


func _ready() -> void:
    for h in handles:
        handles[h].mouse_entered.connect(_on_mouse_entered_element.bind(handles[h]))
        handles[h].mouse_exited.connect(_on_mouse_exited_element.bind(handles[h]))
    dragger.mouse_entered.connect(_on_mouse_entered_element.bind(dragger))
    dragger.mouse_exited.connect(_on_mouse_exited_element.bind(dragger))
    update()

func _process(_delta:float) -> void:
    if dragging or scaling:
        var mouse_position:Vector2 = get_viewport().get_mouse_position()
        var dist:Vector2 = (mouse_position - previous_mouse_position) / camera_zoom
        if dragging:
            handles["NW"].position += dist
            handles["SE"].position += dist
        if scaling:
            x_affected.position.x += dist.x
            y_affected.position.y += dist.y
        update_rect_from_handles()
        update()
        queue_redraw()
    previous_mouse_position = get_viewport().get_mouse_position()

func _unhandled_input(event:InputEvent) -> void:
    if event.is_action_pressed("left_click"):
        if hovered_element != null:
            selected_element = hovered_element
            if selected_element == dragger:
                dragging = true
            else:
                scaling = true
                var scaling_ref:String = handles.find_key(selected_element)
                match scaling_ref:
                    "NW":
                        x_affected = handles["NW"]
                        y_affected = handles["NW"]
                    "NE":
                        x_affected = handles["SE"]
                        y_affected = handles["NW"]
                    "SE":
                        x_affected = handles["SE"]
                        y_affected = handles["SE"]
                    "SW":
                        x_affected = handles["NW"]
                        y_affected = handles["SE"]
            started_editing.emit()
    if event.is_action_released("left_click"):
        if dragging or scaling:
            rect = rect.abs()
            update()
            rect_updated.emit()
            selected_element = null
            dragging = false
            scaling = false

func _draw() -> void:
    draw_rect(rect, color, false)

func update() -> void:
    handles["NW"].set_position(Vector2(rect.position.x, rect.position.y))
    handles["NE"].set_position(Vector2(rect.end.x, rect.position.y))
    handles["SE"].set_position(Vector2(rect.end.x, rect.end.y))
    handles["SW"].set_position(Vector2(rect.position.x, rect.end.y))
    dragger.set_position(rect.position + rect.size/2.)

func update_rect_from_handles() -> void:
    rect.position = handles["NW"].position
    rect.end = handles["SE"].position

func _on_mouse_entered_element(element:CollisionObject2D) -> void:
    if hovered_element == null and element != null:
        hovered_element = element

func _on_mouse_exited_element(element:CollisionObject2D) -> void:
    if hovered_element == element:
        hovered_element = null

static func create(_rect:Rect2, _color:Color) -> EditableRect:
    var edit_rect:EditableRect = load(scene_path).instantiate()
    edit_rect.rect = _rect
    edit_rect.color = _color
    return edit_rect