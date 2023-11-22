extends Node2D

@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_GRAY) # Sets the color of the background
	Events.level_completed.connect(show_level_completed)

func show_level_completed(): # Displays "Level Completed!" screen after collecting all Intel in the level
	level_completed.show()
	get_tree().paused = true
