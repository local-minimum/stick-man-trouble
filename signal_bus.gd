extends Node
class_name _SignalBus

@warning_ignore_start("unused_signal")

signal on_start_level(tick: int)
signal on_end_level(tick: int)
signal on_shot(callibre: int, speed: float, from: Vector3, to: Vector3, hit: Object)
signal on_hit(enemy: Enemy, callibre: int)
signal on_aim(from: Node3D, to: Node3D, width: float)
signal on_remove_aim(from: Node3D)

@warning_ignore_restore("unused_signal")
