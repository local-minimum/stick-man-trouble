extends Node3D

@export var thickness: float = 0.1
@export var mat: Material

var _pool: Array[Line3D]
var _active: Dictionary[Node3D, Array]

func _enter_tree() -> void:
    SignalBus.on_aim.connect(_handle_aim)
    SignalBus.on_remove_aim.connect(_handle_remove_aim)

func _new_line() -> Line3D:
    var line = _pool.pop_back()
    if line != null:
        line.show()
        return line

    line = Line3D.new()
    add_child(line)
    line.start_thickness = thickness
    line.end_thickness = thickness
    line.corner_smooth = 0
    line.cap_smooth = 0
    line.max_points = 2
    line.mat = mat
    line.validate_mesh()

    return line

func _get_aims(from: Node3D) -> Array[Line3D]:
    if _active.has(from):
        return _active[from]

    var left: Line3D = _new_line()
    var right: Line3D = _new_line()
    var lines: Array[Line3D] = [left, right]
    _active[from] = lines
    return lines

func _handle_aim(from: Node3D, to: Node3D, width: float) -> void:
    var aims: Array[Line3D] = _get_aims(from)
    var ortho: Vector3 = to.global_basis.x
    for idx: int in 2:
        var aim: Line3D = aims[idx]
        aim.clear_points()
        aim.add_global_point(from.global_position)
        aim.add_global_point(to.global_position + ortho * (-0.5 if idx == 0 else 0.5) * width)

func _handle_remove_aim(from: Node3D) -> void:
    if !_active.has(from):
        return

    var aims: Array[Line3D] = _active[from]
    _active.erase(from)
    for aim: Line3D in aims:
        aim.hide()
        _pool.append(aim)
