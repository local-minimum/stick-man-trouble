extends Label

var value: int = 3
@export var player: PlayerCharacter
@export var fade_in_time: float = 0.2
@export var show_time: float = 0.4
@export var hide_time: float = 0.4


func _ready() -> void:
    player._paused = true
    _fade_in()

func _fade_in() -> void:
    text = str(value)
    var t: Tween = create_tween()
    t.set_parallel()
    label_settings.font_size = 10
    label_settings.outline_size = 0
    t.tween_property(self.label_settings, "font_size", 360, fade_in_time)
    t.tween_property(self.label_settings, "outline_size", 5, fade_in_time)
    t.finished.connect(_showing)

    if hidden:
        show()

func _showing() -> void:
    if value == 0:
        SignalBus.on_start_level.emit(Time.get_ticks_msec())
    await get_tree().create_timer(show_time).timeout
    hide()
    await get_tree().create_timer(hide_time).timeout
    value -= 1
    if value >= 0:
        _fade_in()
