extends Line2D
class_name UmbilicalCord

var parent:Creature
var child:Creature
var time_to_vanish:float
var timer:Timer


func _ready() -> void:
	add_point(parent.global_position)
	add_point(child.global_position)

	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(queue_free)
	timer.start(time_to_vanish)

	var tween:Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.,1.,1.,0.), time_to_vanish).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "width", 0., time_to_vanish).set_trans(Tween.TRANS_CUBIC)

func _process(_delta:float) -> void:
	if parent != null:
		set_point_position(0, parent.global_position)
	if child != null:
		set_point_position(1, child.global_position)

static func create(_parent:Creature, _child:Creature, _time_to_vanish:float=5.) -> UmbilicalCord:
	var cord = UmbilicalCord.new()
	cord.parent = _parent
	cord.child = _child
	cord.time_to_vanish = _time_to_vanish
	cord.set_z_index(-1)
	cord.set_width(3.)
	return cord