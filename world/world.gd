extends Node2D
class_name World

@export var data:WorldData
var creatures:Array[CreatureVessel]
var foods:Array[Food]

@onready var boundaries:StaticBody2D = find_child("Boundaries")
@onready var creature_container:Node2D = find_child("Creatures")
@onready var food_container:Node2D = find_child("Food")
@onready var camera:WorldCamera = find_child("WorldCamera")
@onready var mini_map:MiniMap = find_child("MiniMap")

@onready var world_elements_container = find_child("WorldElements")
@onready var creature_spawner_list:Control = find_child("CreatureSpawners")
@onready var food_spawner_list:Control = find_child("FoodSpawners")
@onready var obstacle_list:Control = find_child("Obstacles")
@onready var create_c_spawner_bt:Button = find_child("CreateCSpawnerBt")
@onready var create_f_spawner_bt:Button = find_child("CreateFSpawnerBt")
@onready var create_obstacle_bt:Button = find_child("CreateObstacleBt")
@onready var creature_spawner_card:CreatureSpawnerCard = find_child("CreatureSpawnerCard")
@onready var food_spawner_card:FoodSpawnerCard = find_child("FoodSpawnerCard")
var selected_world_element:Node2D
var world_element_selector:WorldElementSelector
var editable_rect:EditableRect

var game_modes:Array[String] = ["sim", "edit"]
var game_mode:String = "sim"

@onready var clock:Clock = find_child("Clock")
var current_gen:int = 0

@export var track_period:float = 1.
var track_timer:Timer
@onready var charts:Control = find_child("Charts")
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
		create_creature_spawner(c_spawner)
	for f_spawner in data.food_spawners:
		create_food_spawner(f_spawner)
	for obs in data.obstacles:
		create_obstacle(obs)

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
	camera.zoom_changed.connect(_on_world_camera_zoom_changed)

	creature_spawner_card.value_changed.connect(_on_creature_spawner_card_updated)
	creature_spawner_card.spawn_pressed.connect(_on_creature_spawner_spawn_pressed)
	food_spawner_card.value_changed.connect(_on_food_spawner_card_updated)
	food_spawner_card.spawn_pressed.connect(_on_food_spawner_spawn_pressed)
	create_c_spawner_bt.pressed.connect(create_creature_spawner)
	create_f_spawner_bt.pressed.connect(create_food_spawner)
	create_obstacle_bt.pressed.connect(create_obstacle)

	toggle_edit_mode()

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("toggle_game_mode"):
		if game_mode == "sim":
			toggle_edit_mode()
		elif game_mode == "edit":
			toggle_sim_mode()
	if game_mode == "sim":
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
	elif game_mode == "edit":
		if event.is_action_pressed("escape"):
			deselect_world_element()
		if event.is_action_pressed("delete"):
			delete_current_world_element()

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
	if game_mode == "sim":
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

func select_world_element(element:Node2D, selector:WorldElementSelector) -> void:
	if element == selected_world_element:
		return
	elif selected_world_element != null:
		deselect_world_element()
	if "data" in element and "area" in element.data:
		editable_rect = EditableRect.create(element.data.area, Color.WHITE)
		add_child(editable_rect)
		editable_rect.camera_zoom = camera.zoom
		editable_rect.started_editing.connect(func(): selected_world_element.set_visible(false))
		editable_rect.rect_updated.connect(func():
			selected_world_element.data.area = editable_rect.rect
			selected_world_element.update()
			selected_world_element.set_visible(true))
		selected_world_element = element
		selector.select_button.set_pressed_no_signal(true)
		world_element_selector = selector
		if element is FoodSpawner:
			food_spawner_card.set_data(element.data)
			food_spawner_card.set_visible(true)
		elif element is CreatureSpawner:
			creature_spawner_card.set_data(element.data)
			creature_spawner_card.set_visible(true)

func deselect_world_element() -> void:
	if selected_world_element != null:
		if editable_rect != null:
			editable_rect.queue_free()
			editable_rect = null
		selected_world_element = null
	if world_element_selector != null:
		world_element_selector.select_button.set_pressed_no_signal(false)
		world_element_selector = null
	creature_spawner_card.set_visible(false)
	food_spawner_card.set_visible(false)

func create_world_element_selector(element:Node2D, _data:Resource, text:String) -> WorldElementSelector:
	var selector = WorldElementSelector.create(_data)
	selector.text = text
	selector.toggled.connect(_on_world_element_button_toggled.bind(element, selector))
	selector.duplicated.connect(duplicate_world_element.bind(element))
	selector.deleted.connect(delete_world_element.bind(element, selector))
	return selector

func _on_world_element_button_toggled(toggled_on:bool, world_element:Node2D, selector:WorldElementSelector) -> void:
	if toggled_on:
		select_world_element(world_element, selector)
	else:
		if selected_world_element == world_element:
			deselect_world_element()

func _on_creature_spawner_card_updated() -> void:
	if selected_world_element is CreatureSpawner:
		selected_world_element.update()

func _on_creature_spawner_spawn_pressed(amount:int) -> void:
	if selected_world_element is CreatureSpawner:
		for i in amount:
			selected_world_element.spawn()

func _on_food_spawner_card_updated() -> void:
	if selected_world_element is FoodSpawner:
		selected_world_element.update()

func _on_food_spawner_spawn_pressed(time:float) -> void:
	if selected_world_element is FoodSpawner:
		var amount:int = int(time * selected_world_element.data.spawn_rate)
		for _a in amount:
			selected_world_element.spawn()

func duplicate_world_element(element:Node2D) -> void:
	if element is CreatureSpawner:
		var _data:CreatureSpawnerData = element.data.duplicate(true)
		create_creature_spawner(_data)
	elif element is FoodSpawner:
		var _data:FoodSpawnerData = element.data.duplicate(true)
		create_food_spawner(_data)
	elif element is Obstacle:
		var _data:ObstacleData = element.data.duplicate(true)
		create_obstacle(_data)

func delete_world_element(element:Node2D, selector:WorldElementSelector) -> void:
	if element == selected_world_element:
		deselect_world_element()
	if element is CreatureSpawner:
		data.creature_spawners.erase(element.data)
	elif element is FoodSpawner:
		data.food_spawners.erase(element.data)
	elif element is Obstacle:
		data.obstacles.erase(element.data)
	element.queue_free()
	selector.queue_free()

func delete_current_world_element() -> void:
	if selected_world_element != null:
		delete_world_element(selected_world_element, world_element_selector)

func create_creature_spawner(_data:CreatureSpawnerData=null) -> void:
	if _data == null:
		_data = CreatureSpawnerData.new()
		_data.area = Rect2(camera.position, Vector2(100.,100.))
	var spawner = CreatureSpawner.create(_data)
	spawner.created_creature.connect(spawn_creature)
	add_child(spawner)
	if _data not in data.creature_spawners:
		data.creature_spawners.append(_data)
	var selector:WorldElementSelector = create_world_element_selector(spawner, _data, "Nascedouro")
	creature_spawner_list.add_child(selector)
	if game_mode == "edit":
		select_world_element(spawner, selector)

func create_food_spawner(_data:FoodSpawnerData=null) -> void:
	if _data == null:
		_data = FoodSpawnerData.create(
			Rect2(camera.position, Vector2(100.,100.)),
			1., Color.WHITE, 0., 10., 60.)
	var spawner = FoodSpawner.create(_data)
	spawner.created_food.connect(spawn_food)
	add_child(spawner)
	if _data not in data.food_spawners:
		data.food_spawners.append(_data)
	var selector:WorldElementSelector = create_world_element_selector(spawner, _data, "Comedouro")
	food_spawner_list.add_child(selector)
	if game_mode == "edit":
		select_world_element(spawner, selector)

func create_obstacle(_data:ObstacleData=null) -> void:
	if _data == null:
		_data = ObstacleData.create(
			Rect2(camera.position, Vector2(100.,100.)),
			data.boundary_texture)
	var obstacle = Obstacle.create(_data)
	add_child(obstacle)
	if _data not in data.obstacles:
		data.obstacles.append(_data)
	var selector:WorldElementSelector = create_world_element_selector(obstacle, _data, "Obstáculo")
	obstacle_list.add_child(selector)
	if game_mode == "edit":
		select_world_element(obstacle, selector)

func _on_world_camera_zoom_changed() -> void:
	if editable_rect != null:
		editable_rect.camera_zoom = camera.zoom

func toggle_edit_mode() -> void:
	clock.toggle_pause(true)
	unhover_creature()
	unfeature_creature()
	uncompare_creature()
	charts.set_visible(false)
	world_elements_container.set_visible(true)
	game_mode = "edit"

func toggle_sim_mode() -> void:
	deselect_world_element()
	world_elements_container.set_visible(false)
	charts.set_visible(true)
	game_mode = "sim"
