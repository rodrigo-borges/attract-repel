extends Control
class_name LineChart

@onready var plot:LinePlot = find_child("LinePlot")
@onready var label:Label = find_child("CurrentValue")
@onready var title_label:Label = find_child("Title")
@export var chart_name:String = "Título"
@export var line_color:Color = Color.WHITE
@export var line_width:float = 2.
@export var values_to_show:int = 60
var values:Array[float]
var max_value:float
var min_value:float


func _ready() -> void:
	plot.line_color = line_color
	plot.line_width = line_width
	title_label.set_text(chart_name)
	label.set_text("")

func _process(_delta:float) -> void:
	pass

func add_value(value:float) -> void:
	if values.is_empty():
		max_value = value + 1.
		min_value = value - 1.
	else:
		max_value = maxf(value, max_value)
		min_value = minf(value, min_value)
	values.append(value)
	while values.size() > values_to_show:
		values.pop_front()
	update()

func update() -> void:
	if values.size() < 2:
		return
	var spacing:float = plot.size.x/(values.size()-1.)
	var value_scale:float = plot.size.y/(max_value-min_value)
	var points:PackedVector2Array = PackedVector2Array()
	for i in values.size():
		var x:float = i*spacing
		var y:float = plot.size.y - (values[i]-min_value)*value_scale
		points.append(Vector2(x,y))
	plot.points = points
	plot.queue_redraw()
	label.position.y = plot.size.y - (values[-1]-min_value)*value_scale - label.size.y/2.
	if abs(values[-1]) < 10.:
		label.set_text("%3.1f" % values[-1])
	elif abs(values[-1]) < 1000.:
		label.set_text("%3.0f" % values[-1])
	else:
		label.set_text("%3.1fk" % (values[-1]/1000.))