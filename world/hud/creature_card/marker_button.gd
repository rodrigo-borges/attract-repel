extends OptionButton
class_name MarkerButton

signal marker_selected(marker:Marker)

@export var markers:Array[Marker]


func _ready() -> void:
	add_item(" ")
	for m in markers:
		add_icon_item(m.texture, m.resource_name)
	item_selected.connect(_on_item_selected)

func update_marker_from_creature(creature:CreatureData) -> void:
	var idx:int = 0
	if creature.marker != null:
		idx = markers.find(creature.marker) + 1
	select(idx)

func get_selected_marker() -> Marker:
	return get_marker_from_idx(selected)

func get_marker_from_idx(idx:int) -> Marker:
	var marker:Marker = null
	if idx > 0:
		marker = markers[idx-1]
	return marker

func _on_item_selected(idx:int) -> void:
	var marker:Marker = get_marker_from_idx(idx)
	marker_selected.emit(marker)