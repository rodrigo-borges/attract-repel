extends Node2D
class_name FamilyTree

signal creature_selected(creature:CreatureData)

@export var layers_above:int = 1
@export var layers_below:int = 1
@export var h_spacing:float = 35.
@export var v_spacing:float = 50.
@onready var camera:Camera2D = find_child("Camera")
var creature:CreatureData
var creature_node:FamilyNode
var creatures:Array[CreatureData]
var family_nodes:Array[FamilyNode]
var lines:Array[Line2D]
var final_layer_size:int
var first_layer:int

@onready var select_highlight:FamilyNodeHighlight = find_child("SelectHighlight")
@onready var hover_highlight:FamilyNodeHighlight = find_child("HoverHighlight")
var hovered_node:FamilyNode

@onready var l_above_input:SpinBox = find_child("LayersAbove")
@onready var l_below_input:SpinBox = find_child("LayersBelow")


func _ready() -> void:
	l_above_input.set_value(layers_above)
	l_below_input.set_value(layers_below)
	l_above_input.value_changed.connect(func(value:float):layers_above=int(value);refresh())
	l_below_input.value_changed.connect(func(value:float):layers_below=int(value);refresh())

func _process(_delta:float) -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if hovered_node != null:
			creature_selected.emit(hovered_node.creature)

func set_creature(_creature:CreatureData, reset_camera:bool=true) -> void:
	clear()
	creature = _creature
	create_tree()
	if reset_camera:
		camera.set_position(creature_node.position)

func refresh() -> void:
	set_creature(creature, false)

func clear() -> void:
	unhover_node()
	creature = null
	creature_node = null
	creatures = []
	while not family_nodes.is_empty():
		var n:FamilyNode = family_nodes.pop_back()
		if n.creature.vessel != null:
			n.creature.vessel.reproduced.disconnect(refresh)
			n.creature.vessel.died.disconnect(refresh)
		remove_child(n)
		n.queue_free()
	while not lines.is_empty():
		var l:Line2D = lines.pop_back()
		remove_child(l)
		l.queue_free()
	final_layer_size = 0

func create_tree() -> void:
	if creature != null:
		var layer:int = layers_above
		var eldest:CreatureData = creature
		for i in layers_above:
			if eldest.parent == null:
				break
			else:
				eldest = eldest.parent
				layer -= 1
		first_layer = layer
		create_family_node(eldest, layer)
		select_highlight.set_position(creature_node.position)
		unhover_node()

func create_family_node(_creature:CreatureData, layer:int) -> FamilyNode:
	var node:FamilyNode = FamilyNode.create(_creature)
	if _creature.vessel != null:
		_creature.vessel.reproduced.connect(refresh.unbind(1))
		_creature.vessel.died.connect(refresh)
	var pos:Vector2
	if layer == layers_above + layers_below:
		pos = Vector2(final_layer_size*h_spacing, v_spacing*layer)
		place_family_node(node, pos)
		if _creature.children.size() > 0:
			var line:Line2D = create_connection_line()
			line.set_points([pos, pos+Vector2(0., v_spacing/2.)])
		final_layer_size += 1
	else:
		var children_nodes:Array[FamilyNode] = []
		for c in _creature.children:
			var c_node:FamilyNode = create_family_node(c, layer+1)
			children_nodes.append(c_node)
		if children_nodes.is_empty():
			pos = Vector2(final_layer_size*h_spacing, v_spacing*layer)
			place_family_node(node, pos)
			final_layer_size += 1
		else:
			var x0:float = children_nodes[0].position.x
			var x1:float = children_nodes[-1].position.x
			pos = Vector2((x0+x1)/2., v_spacing*layer)
			place_family_node(node, pos)
			for c_n in children_nodes:
				connect_nodes(node, c_n)
		if layer == first_layer:
			if _creature.parent != null:
				var line:Line2D = create_connection_line()
				line.set_points([pos, pos-Vector2(0.,v_spacing/2.)])
	if _creature == creature:
		creature_node = node
	return node

func place_family_node(node:FamilyNode, pos:Vector2) -> void:
	add_child(node)
	node.mouse_entered.connect(_on_node_mouse_entered.bind(node))
	node.mouse_exited.connect(_on_node_mouse_exited.bind(node))
	node.set_position(pos)
	family_nodes.append(node)

func connect_nodes(n0:FamilyNode, n1:FamilyNode) -> void:
	var line = create_connection_line()
	line.set_points([n0.position, n1.position])

func create_connection_line() -> Line2D:
	var line = Line2D.new()
	line.set_width(2.)
	line.set_default_color(Color(1.,1.,1.,.2))
	line.set_z_index(-1)
	add_child(line)
	lines.append(line)
	return line

func _on_node_mouse_entered(node:FamilyNode) -> void:
	hover_node(node)

func _on_node_mouse_exited(node:FamilyNode) -> void:
	if hovered_node == node:
		unhover_node()

func hover_node(node:FamilyNode) -> void:
	if hovered_node != null:
		unhover_node()
	if hovered_node != node:
		hover_highlight.set_position(node.position)
		hover_highlight.set_visible(true)
		hovered_node = node

func unhover_node() -> void:
	if hovered_node != null:
		hover_highlight.set_visible(false)
		hovered_node = null