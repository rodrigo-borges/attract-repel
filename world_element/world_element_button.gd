extends Button
class_name WorldElementButton

static var scene_path:String = "res://world_element/world_element_button.tscn"

var data:Resource

static func create(_data:Resource) -> WorldElementButton:
    var button:WorldElementButton = load(scene_path).instantiate()
    button.data = _data
    return button