extends Area3D
class_name PlayerCharacter

@export var max_speed: float = 20.0
@export var min_speed: float = 1.0
@export var acceleration: float = 1.0
@export var lateral_speed_factor: float = 5.0
@export var road_direction: Vector3 = Vector3(0.0, 0.0, -1.0)
@export var road_right: Vector3 = Vector3(1.0, 0.0, 0.0)
@export var road_width: float = 6.0
@export var road_overshoot: float = -1.0

var _road_position: Vector3
var _speed: float = 0.0
var _lateral_speed: float = 0.0
var _paused: bool

func _input(event: InputEvent) -> void:
    if event.is_action_pressed(&"player_left"):
        _lateral_speed = -abs(event.get_action_strength(&"player_left"))
    elif event.is_action_pressed(&"player_right"):
        _lateral_speed = abs(event.get_action_strength(&"player_right"))
    elif event.is_action_released(&"player_left") && _lateral_speed < 0:
        _lateral_speed = 0.0
    elif event.is_action_released(&"player_right") && _lateral_speed > 0:
        _lateral_speed = 0.0
    elif event.is_action_pressed(&"pause"):
        _paused = !_paused

func _process(delta: float) -> void:
    if _paused:
        return

    _set_current_road_position()

    # Update speed
    _speed += acceleration * delta
    if _speed > max_speed:
        _speed = max_speed

    if _lateral_speed != 0:
        var lateral: Vector3 = global_position - _road_position
        lateral += lateral_speed_factor * _lateral_speed * delta * road_right
        lateral = lateral.limit_length(road_width * 0.5 + road_overshoot)
        global_position = _road_position + lateral + _speed * road_direction * delta
    else:
        global_position += _speed * road_direction * delta

func _set_current_road_position():
    # This is a bit of a hack
    _road_position = global_position
    _road_position.x = 0
