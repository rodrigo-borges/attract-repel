extends Resource
class_name CreatureSpawnerData

@export var area:Rect2
@export var color_mean:Color = Color.DIM_GRAY
@export var color_std:float
@export var size_radius_mean:float = 10.
@export var size_radius_std:float
@export var sense_radius_mean:float = 100.
@export var sense_radius_std:float
@export var attraction_mean:Vector3
@export var attraction_std:float = .25
@export var intensity_mean:float = 5.
@export var intensity_std:float
@export var aggression_mean:Vector3
@export var aggression_std:float = .25
@export var aggression_intensity_mean:float = 5.
@export var aggression_intensity_std:float
@export var aggression_energy_threshold_mean:float = 50.
@export var aggression_energy_threshold_std:float
@export var reproduction_energy_threshold_mean:float = 50.
@export var reproduction_energy_threshold_std:float
@export var reproduction_cooldown_mean:float = 10.
@export var reproduction_cooldown_std:float
@export var brake_mean:float = .5
@export var brake_std:float
@export var incubation_time_mean:float = 5.
@export var incubation_time_std:float