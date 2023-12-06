extends Node2D

@export var next_level: PackedScene

var level_time = 0.0
var start_level_msec = 0.0

@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var level_time_label = %LevelTimeLabel

func _ready():
	Events.level_completed.connect(show_level_completed)
	start_level_msec = Time.get_ticks_msec()

func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time / 1000.0)

func show_level_completed(): # Displays "Level Completed!" screen after collecting all Intel in the level
	level_completed.show()
	get_tree().paused = true
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
