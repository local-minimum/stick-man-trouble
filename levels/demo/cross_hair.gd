extends Control
@export var player: PlayerCharacter


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.mouse_mode != Input.MOUSE_MODE_CONFINED_HIDDEN:
            Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

        var mevt: InputEventMouseMotion = event
        var pos = mevt.global_position

        global_position = pos
        player.aim_crosshair(pos)
