extends Label

var _start: int
var _running: bool = false

func _enter_tree() -> void:
    SignalBus.on_start_level.connect(_handle_start_level)
    SignalBus.on_end_level.connect(_handle_end_level)

func _ready() -> void:
    hide()

func _handle_start_level(tick: int) -> void:
    show()
    _start = tick
    _running = true
    _update_clock(tick)

func _handle_end_level(tick: int) -> void:
    _running = false
    _update_clock(tick, true)

func _update_clock(tick: int, show_millis: bool = false) -> void:
    var runtime: int = tick - _start
    var seconds: int = runtime / 1000
    var minutes: int = seconds / 60
    seconds -= minutes * 60
    var millis: int = runtime % 1000
    var part: int = millis / 100
    if show_millis:
        if minutes > 0:
            text = "%d:%02d.%03d" % [minutes, seconds, millis]
        else:
            text = "%02d.%03d" % [seconds, millis]
    elif minutes > 0:
        text = "%d:%02d.%d" % [minutes, seconds, part]
    else:
        text = "%02d.%d" % [seconds, part]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if _running:
        _update_clock(Time.get_ticks_msec())
