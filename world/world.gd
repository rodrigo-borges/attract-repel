extends Node2D
class_name World

@export var data:WorldData
var creatures:Array[CreatureVessel]
var foods:Array[Food]
var creature_spawners:Array[CreatureSpawner]
var food_spawners:Array[FoodSpawner]
var obstacles:Array[Obstacle]

@onready var boundaries:StaticBody2D = find_child("Boundaries")
@onready var creature_container:Node2D = find_child("Creatures")
@onready var food_container:Node2D = find_child("Food")
@onready var camera:WorldCamera = $WorldCamera
@onready var mini_map:MiniMap = find_child("MiniMap")

@onready var clock:Clock = find_child("Clock")
var current_gen:int = 0

@export var track_period:float = 1.
var track_timer:Timer
@onready var pop_chart:LineChart = find_child("PopChart")
@onready var lifespan_chart:LineChart = find_child("LifespanChart")
@onready var food_chart:LineChart = find_child("FoodChart")
@onready var energy_chart:LineChart = find_child("EnergyChart")
@onready var children_chart:LineChart = find_child("ChildrenChart")
@onready var momentum_chart:LineChart = find_child("MomentumChart")
var c_population:int
var c_lifespan:float
var c_food_available:float
var c_energy_pool:float
var c_avg_children:float
var c_momentum:float

@onready var hover_highlight:CreatureHighlight = find_child("HoverHighlight")
@onready var select_highlight:CreatureHighlight = find_child("SelectHighlight")
@onready var creature_card:CreatureCard = find_child("CreatureCard")
@onready var comparison_card:CreatureCard = find_child("ComparisonCard")
var hovered_creature:CreatureVessel
var selected_creature:CreatureVessel
var featured_creature:CreatureData
var compared_creature:CreatureData
var follow_bt:Button
var followed_creature:CreatureVessel

@onready var tree_container:Control = find_child("TreeContainer")
@onready var family_tree:FamilyTree = find_child("FamilyTree")


func _ready() -> void:
	for c_spawner in data.creature_spawners:
		var spawner = CreatureSpawner.create(c_spawner)
		spawner.created_creature.connect(spawn_creature)
		creature_spawners.append(spawner)
		add_child(spawner)
	
	for f_spawner in data.food_spawners:
		var spawner = FoodSpawner.create(f_spawner)
		spawner.created_food.connect(spawn_food)
		add_child(spawner)
		food_spawners.append(spawner)
	call_deferred("spawn_initial_food")

	for obs in data.obstacles:
		var obstacle = Obstacle.create(obs)
		add_child(obstacle)
		obstacles.append(obstacle)
	
	create_world_boundary(Vector2.DOWN, data.area.position.y)
	create_world_boundary(Vector2.UP, -data.area.end.y)
	create_world_boundary(Vector2.LEFT, -data.area.end.x)
	create_world_boundary(Vector2.RIGHT, data.area.position.x)

	track_timer = Timer.new()
	add_child(track_timer)
	track_timer.timeout.connect(update_counters)
	track_timer.start(track_period)

	hover_highlight.set_visible(false)
	select_highlight.set_visible(false)
	creature_card.set_visible(false)
	comparison_card.set_visible(false)
	tree_container.set_visible(false)
	family_tree.creature_hovered.connect(_on_creature_hovered_on_tree)
	family_tree.creature_selected.connect(feature_creature)

	follow_bt = creature_card.follow_button
	follow_bt.toggled.connect(toggle_follow)

	camera.area = data.area
	camera.set_position(data.area.position + data.area.size/2.)

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if hovered_creature != null:
			feature_creature(hovered_creature.data)
		else:
			unfeature_creature()
	if event.is_action_pressed("escape"):
		unfeature_creature()
	if event.is_action_pressed("follow"):
		if selected_creature != null:
			toggle_follow(followed_creature == null)

func _draw() -> void:
	draw_rect(data.area, Color.BLACK, false)
	if data.boundary_texture != null:
		var w:float = data.boundary_width
		var v_size:Vector2 = Vector2(w, data.area.size.y)
		var h_size:Vector2 = Vector2(data.area.size.x, w)
		draw_texture_rect(data.boundary_texture, Rect2(data.area.position-Vector2(0.,w), h_size), true, Color.BLACK)
		draw_texture_rect(data.boundary_texture, Rect2(data.area.position+Vector2(0.,data.area.size.y), h_size), true, Color.BLACK)
		draw_texture_rect(data.boundary_texture, Rect2(data.area.position+Vector2(data.area.size.x,0.), v_size), true, Color.BLACK)
		draw_texture_rect(data.boundary_texture, Rect2(data.area.position-Vector2(w,0.), v_size), true, Color.BLACK)

func create_world_boundary(normal:Vector2, distance:float) -> void:
	var shape_node = CollisionShape2D.new()
	boundaries.add_child(shape_node)
	var shape = WorldBoundaryShape2D.new()
	shape.set_normal(normal)
	shape.set_distance(distance)
	shape_node.set_shape(shape)

func spawn_initial_food() -> void:
	for s in food_spawners:
		var amount:int = int(data.initial_food_spawn_time * s.data.spawn_rate)
		for _a in amount:
			s.spawn()

func spawn_food(food:Food, pos:Vector2) -> void:
	food_container.add_child(food)
	food.set_global_position(pos)
	food.tree_exited.connect(foods.erase.bind(food))
	foods.append(food)

func spawn_creature(creature:CreatureData, pos:Vector2) -> void:
	var vessel = CreatureVessel.create(creature)
	spawn_vessel(vessel, pos)

func spawn_vessel(vessel:CreatureVessel, pos:Vector2) -> void:
	creature_container.add_child(vessel)
	vessel.set_global_position(pos)
	vessel.reproduced.connect(_on_reproduction.bind(vessel))
	vessel.created_food.connect(_on_food_creation.bind(vessel))
	vessel.died.connect(creatures.erase.bind(vessel))
	vessel.mouse_entered.connect(_on_creature_mouse_entered.bind(vessel))
	vessel.mouse_exited.connect(_on_creature_mouse_exited.bind(vessel))
	creatures.append(vessel)

func _on_food_creation(food:Food, creature:CreatureVessel) -> void:
	spawn_food(food, creature.global_position)

func _on_reproduction(child:CreatureVessel, parent:CreatureVessel) -> void:
	spawn_vessel(child, parent.global_position + Vector2(randf()*50., randf()*50.))
	var cord = UmbilicalCord.create(parent, child)
	add_child(cord)
	current_gen = maxi(current_gen, child.data.generation)
	clock.gen_label.set_text("Geração %d" % current_gen)

func update_counters() -> void:
	c_population = creatures.size()
	
	c_lifespan = 0.
	c_energy_pool = 0.
	c_avg_children = 0.
	c_momentum = 0.
	for c in creatures:
		c_lifespan += c.lifespan
		c_energy_pool += c.energy
		c_avg_children += c.data.children.size()
		c_momentum += c.total_force.length()
	c_lifespan /= creatures.size()
	c_avg_children /= creatures.size()
	
	c_food_available = 0.
	for f in foods:
		c_food_available += f.energy_provided
	
	pop_chart.add_value(c_population)
	lifespan_chart.add_value(c_lifespan)
	food_chart.add_value(c_food_available)
	energy_chart.add_value(c_energy_pool)
	children_chart.add_value(c_avg_children)
	momentum_chart.add_value(c_momentum)

func _on_creature_mouse_entered(creature:CreatureVessel) -> void:
	hover_creature(creature)

func _on_creature_mouse_exited(creature:CreatureVessel) -> void:
	if hovered_creature == creature:
		unhover_creature()

func hover_creature(creature:CreatureVessel) -> void:
	if hovered_creature != null:
		unhover_creature()
	if hovered_creature != creature:
		hover_highlight.creature = creature
		hover_highlight.set_visible(true)
		hover_highlight.queue_redraw()
		creature.died.connect(unhover_creature)
		if creature.data != featured_creature:
			compare_creature(creature.data)
		hovered_creature = creature

func unhover_creature() -> void:
	if hovered_creature != null:
		hovered_creature.died.disconnect(unhover_creature)
		hover_highlight.creature = null
		hover_highlight.set_visible(false)
		uncompare_creature()
		hovered_creature = null

func select_creature(creature:CreatureVessel) -> void:
	if selected_creature != null:
		deselect_creature()
	if selected_creature != creature:
		creature.died.connect(deselect_creature)
		creature.toggle_details(true)
		select_highlight.creature = creature
		select_highlight.set_visible(true)
		select_highlight.queue_redraw()
		unfollow_creature()
		selected_creature = creature

func deselect_creature() -> void:
	if selected_creature != null:
		selected_creature.died.disconnect(deselect_creature)
		selected_creature.toggle_details(false)
		select_highlight.creature = null
		select_highlight.set_visible(false)
		unfollow_creature()
		selected_creature = null

func feature_creature(creature:CreatureData) -> void:
	if featured_creature != null:
		unfeature_creature()
	creature_card.set_creature(creature)
	creature_card.set_visible(true)
	family_tree.set_creature(creature)
	tree_container.set_visible(true)
	if creature.vessel != null:
		select_creature(creature.vessel)
	if creature == compared_creature:
		uncompare_creature()
	featured_creature = creature

func unfeature_creature() -> void:
	if featured_creature != null:
		creature_card.set_creature(null)
		creature_card.set_visible(false)
		family_tree.clear()
		tree_container.set_visible(false)
		deselect_creature()
		featured_creature = null

func compare_creature(creature:CreatureData) -> void:
	if compared_creature != null:
		uncompare_creature()
	if compared_creature != creature:
		comparison_card.set_creature(creature)
		comparison_card.set_visible(true)
		compared_creature = creature

func uncompare_creature() -> void:
	if compared_creature != null:
		comparison_card.set_creature(null)
		comparison_card.set_visible(false)
		compared_creature = null

func _on_creature_hovered_on_tree(creature:CreatureData) -> void:
	if creature != null and creature != featured_creature:
		if creature.vessel != null:
			hover_creature(creature.vessel)
		else:
			compare_creature(creature)
	else:
		unhover_creature()
		uncompare_creature()

func toggle_follow(toggled_on:bool) -> void:
	if toggled_on:
		follow_creature(selected_creature)
	else:
		unfollow_creature()

func follow_creature(creature:CreatureVessel) -> void:
	if followed_creature != null:
		unfollow_creature()
	if followed_creature != creature:
		camera.followed_node = creature
		follow_bt.set_pressed_no_signal(true)
		creature.died.connect(unfollow_creature)
		followed_creature = creature
	
func unfollow_creature() -> void:
	if followed_creature != null:
		followed_creature.died.disconnect(unfollow_creature)
		camera.followed_node = null
		follow_bt.set_pressed_no_signal(false)
		followed_creature = null
