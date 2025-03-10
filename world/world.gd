extends Node2D
class_name World

static var area:Rect2 = Rect2(Vector2.ZERO, Vector2(2000., 2000.))

@export var n_creatures:int = 10
@export var initial_food_spawn_time:int = 30
var creatures:Array[Creature]
var foods:Array[Food]
var food_spawners:Array[FoodSpawner]

@onready var camera:WorldCamera = $WorldCamera
@onready var mini_map:MiniMap = find_child("MiniMap")

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
var hovered_creature:Creature
var selected_creature:Creature


func _ready() -> void:
	create_spawner(Rect2(Vector2(0., 0.), Vector2(1100.,1600.)), 2., Color(.75,.5,.05), 10., 60.)
	create_spawner(Rect2(Vector2(900., 0.), Vector2(1100.,1600.)), 4., Color(.05,.5,.75), 10., 60.)
	create_spawner(Rect2(Vector2(0.,1100.), Vector2(2000.,900.)), 2., Color(.05,.9,.05), -20., 60.)
	create_spawner(Rect2(Vector2(0.,0.), Vector2(2000.,1100.)), .5, Color(.05,.9,.05), -40., 60.)
	
	for i in n_creatures:
		spawn_creature(
			Creature.create(
				Color(randf(), randf(), randf()), 10.,
				Vector3(randfn(0., 1.), randfn(0., 1.), randfn(0., 1.)).normalized(), randfn(2., 1.), randfn(100., 5.),
				randfn(70., 5.), randfn(10., 1.),
				randfn(.5, .1)),
			Vector2(randf()*area.size.x, randf()*area.size.y))

	track_timer = Timer.new()
	add_child(track_timer)
	track_timer.timeout.connect(update_counters)
	track_timer.start(track_period)

	hover_highlight.set_visible(false)
	select_highlight.set_visible(false)
	creature_card.set_visible(false)

	call_deferred("spawn_initial_food")

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if hovered_creature != null:
			select_creature(hovered_creature)
		else:
			unselect_creature()
	if event.is_action_pressed("escape"):
		unselect_creature()

func _draw() -> void:
	draw_rect(area, Color.BLACK, false)

func create_spawner(_area:Rect2, rate:float, color:Color, energy:float, decay_time:float) -> void:
	var spawner:FoodSpawner = FoodSpawner.create(_area, rate, color, energy, decay_time)
	add_child(spawner)
	spawner.created_food.connect(spawn_food)
	food_spawners.append(spawner)

func spawn_initial_food() -> void:
	for s in food_spawners:
		var amount:int = int(initial_food_spawn_time * s.spawn_rate)
		for _a in amount:
			s.spawn()

func spawn_food(food:Food, pos:Vector2) -> void:
	add_child(food)
	food.set_global_position(pos)
	food.tree_exited.connect(foods.erase.bind(food))
	foods.append(food)

func spawn_creature(creature:Creature, pos:Vector2) -> void:
	add_child(creature)
	creature.set_global_position(pos)
	creature.reproduced.connect(_on_reproduction.bind(creature))
	creature.created_food.connect(_on_food_creation.bind(creature))
	creature.died.connect(creatures.erase.bind(creature))
	creature.mouse_entered.connect(_on_creature_mouse_entered.bind(creature))
	creature.mouse_exited.connect(_on_creature_mouse_exited.bind(creature))
	creatures.append(creature)

func _on_food_creation(food:Food, creature:Creature) -> void:
	spawn_food(food, creature.global_position)

func _on_reproduction(child:Creature, parent:Creature) -> void:
	spawn_creature(child, parent.global_position + Vector2(randf()*50., randf()*50.))
	var cord = UmbilicalCord.create(parent, child)
	add_child(cord)

func update_counters() -> void:
	c_population = creatures.size()
	
	c_lifespan = 0.
	c_energy_pool = 0.
	c_avg_children = 0.
	c_momentum = 0.
	for c in creatures:
		c_lifespan += c.lifespan
		c_energy_pool += c.energy
		c_avg_children += c.children
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

func _on_creature_mouse_entered(creature:Creature) -> void:
	hover_creature(creature)

func _on_creature_mouse_exited(creature:Creature) -> void:
	if hovered_creature == creature:
		unhover_creature()

func hover_creature(creature:Creature) -> void:
	if hovered_creature != null and hovered_creature.died.is_connected(unhover_creature):
		hovered_creature.died.disconnect(unhover_creature)
	hover_highlight.creature = creature
	hover_highlight.set_visible(true)
	hover_highlight.queue_redraw()
	creature.died.connect(unhover_creature)
	hovered_creature = creature

func unhover_creature() -> void:
	if hovered_creature != null:
		hovered_creature.died.disconnect(unhover_creature)
		hover_highlight.creature = null
		hover_highlight.set_visible(false)
		hovered_creature = null

func select_creature(creature:Creature) -> void:
	if selected_creature != null and selected_creature.died.is_connected(unselect_creature):
		selected_creature.died.disconnect(unselect_creature)
	select_highlight.creature = creature
	select_highlight.set_visible(true)
	select_highlight.queue_redraw()
	creature_card.creature = creature
	creature_card.set_visible(true)
	creature.died.connect(unselect_creature)
	selected_creature = creature

func unselect_creature() -> void:
	if selected_creature != null:
		selected_creature.died.disconnect(unselect_creature)
		select_highlight.creature = null
		select_highlight.set_visible(false)
		creature_card.creature = null
		creature_card.set_visible(false)
		selected_creature = null
