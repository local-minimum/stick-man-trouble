extends Node3D

@export_file("*.tscn") var _bullet_templates: Array[String]
@export var _bullet_speeds: Array[float] = [20.0]

var _pools: Array[Array]

func _enter_tree() -> void:
    if SignalBus.on_shot.connect(_handle_shoot) != OK:
        push_error("Failed to connect shoot")

func _ready() -> void:
    _pools.append([] as Array[Node3D])

func _spawn_new_shot(calibre: int) -> Node3D:
    var scene: PackedScene = ResourceLoader.load(_bullet_templates[calibre])
    var bullet: Node3D = scene.instantiate()
    add_child(bullet)

    return bullet

func _handle_shoot(calibre: int, from: Vector3, to: Vector3, hit: Object) -> void:
    var pool: Array[Node3D] = _pools[calibre]
    if pool.is_empty():
        pool.append(_spawn_new_shot(calibre))

    var shot: Node3D = pool.pop_back()

    shot.global_position = from
    shot.look_at(to)
    shot.visible = true

    var collided: bool = false
    var velocity: Vector3 = (to - from).normalized() * _bullet_speeds[calibre]
    var collision_distance: float = from.distance_squared_to(to)
    while !collided:
        await get_tree().create_timer(0.02).timeout
        shot.global_position += velocity * 0.02
        collided = shot.global_position.distance_squared_to(from) >= collision_distance

    if hit is Enemy:
        SignalBus.on_hit.emit(hit as Enemy, calibre)

    shot.visible = false
    pool.append(shot)
