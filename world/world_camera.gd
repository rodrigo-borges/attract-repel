extends Camera
class_name WorldCamera

var followed_node:Node2D = null


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	super._process(_delta)
	if followed_node != null:
		global_position = followed_node.global_position