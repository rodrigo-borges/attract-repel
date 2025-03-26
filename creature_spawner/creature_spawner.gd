extends Node2D
class_name CreatureSpawner

signal created_creature(creature:CreatureData, pos:Vector2)

@export var data:CreatureSpawnerData


func _ready() -> void:
	set_z_index(-2)

func _draw() -> void:
	var x0:float = data.area.position.x
	var y0:float = data.area.position.y
	var x1:float = data.area.end.x
	var y1:float = data.area.end.y
	var dash_length:float = 10.
	draw_dashed_line(Vector2(x0, y0), Vector2(x1, y0), data.color_mean, -1., dash_length)
	draw_dashed_line(Vector2(x1, y0), Vector2(x1, y1), data.color_mean, -1., dash_length)
	draw_dashed_line(Vector2(x1, y1), Vector2(x0, y1), data.color_mean, -1., dash_length)
	draw_dashed_line(Vector2(x0, y1), Vector2(x0, y0), data.color_mean, -1., dash_length)
	draw_rect(data.area, data.color_mean*Color(1.,1.,1.,.05))

func update() -> void:
	if data != null:
		queue_redraw()

func spawn() -> void:
	var color:Color = data.color_mean + Color(randfn(0., data.color_std), randfn(0., data.color_std), randfn(0., data.color_std))
	var size_radius:float = randfn(data.size_radius_mean, data.size_radius_std)
	var sense_radius:float = randfn(data.sense_radius_mean, data.sense_radius_std)
	var attraction:Vector3 = (data.attraction_mean + Vector3(randfn(0., data.attraction_std), randfn(0., data.attraction_std), randfn(0., data.attraction_std))).normalized()
	var intensity:float = randfn(data.intensity_mean, data.intensity_std)
	var aggression:Vector3 = (data.aggression_mean + Vector3(randfn(0., data.aggression_std), randfn(0., data.aggression_std), randfn(0., data.aggression_std))).normalized()
	var aggression_intensity:float = randfn(data.aggression_intensity_mean, data.aggression_intensity_std)
	var aggression_energy_threshold:float = randfn(data.aggression_energy_threshold_mean, data.aggression_energy_threshold_std)
	var reproduction_energy_threshold:float = randfn(data.reproduction_energy_threshold_mean, data.reproduction_energy_threshold_std)
	var reproduction_cooldown:float = randfn(data.reproduction_cooldown_mean, data.reproduction_cooldown_std)
	var brake:float = randfn(data.brake_mean, data.brake_std)
	var incubation_time:float = randfn(data.incubation_time_mean, data.incubation_time_std)
	
	var creature:CreatureData = CreatureData.create(
		color, size_radius, attraction, intensity, aggression, aggression_intensity, aggression_energy_threshold,
		sense_radius, reproduction_energy_threshold, reproduction_cooldown, brake, incubation_time)
	var pos:Vector2 = Vector2(randf()*data.area.size.x+data.area.position.x, randf()*data.area.size.y+data.area.position.y)
	created_creature.emit(creature, pos)

static func create(_data:CreatureSpawnerData) -> CreatureSpawner:
	var spawner = CreatureSpawner.new()
	spawner.data = _data
	return spawner
