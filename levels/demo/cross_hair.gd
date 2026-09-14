extends Control

@export var player: PlayerCharacter
@export var controller_sense: float = 1.0

var _virt_aim: Vector2

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.mouse_mode != Input.MOUSE_MODE_CONFINED_HIDDEN:
            Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

        var mevt: InputEventMouseMotion = event
        global_position = mevt.global_position

        player.aim_crosshair(global_position)

    if event.is_action_pressed(&"aim_left"):
        _virt_aim.x = -event.get_action_strength(&"aim_left")
    elif event.is_action_released(&"aim_left"):
        _virt_aim.x = maxf(_virt_aim.x, 0.0)
    if event.is_action_pressed(&"aim_right"):
        _virt_aim.x = event.get_action_strength(&"aim_right")
    elif event.is_action_released(&"aim_right"):
        _virt_aim.x = minf(_virt_aim.x, 0.0)

    if event.is_action_pressed(&"aim_up"):
        _virt_aim.y = -event.get_action_strength(&"aim_up")
    elif event.is_action_released(&"aim_up"):
        _virt_aim.y = maxf(_virt_aim.y, 0.0)

    if event.is_action_pressed(&"aim_down"):
        _virt_aim.y = event.get_action_strength(&"aim_down")
    elif event.is_action_released(&"aim_down"):
        _virt_aim.y = minf(_virt_aim.y, 0.0)

func _process(delta: float) -> void:
    if _virt_aim == Vector2.ZERO || player.is_paused():
        return

    var bounds: Rect2 = get_viewport_rect()

    global_position = (global_position + _virt_aim * delta * controller_sense * bounds.size).clamp(bounds.position, bounds.end)
    player.aim_crosshair(global_position)
