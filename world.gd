extends Node2D

@export var next_level: PackedScene

@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_GRAY) # Sets the color of the background
	Events.level_completed.connect(show_level_completed)

func show_level_completed(): # Displays "Level Completed!" screen after collecting all Intel in the level
	level_completed.show()
	get_tree().paused = true
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
