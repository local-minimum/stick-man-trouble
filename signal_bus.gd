extends Node
class_name _SignalBus

@warning_ignore_start("unused_signal")

signal on_shot(callibre: int, from: Vector3, to: Vector3, hit: Object)
signal on_hit(enemy: Enemy, callibre: int)

@warning_ignore_restore("unused_signal")
