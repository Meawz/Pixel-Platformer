extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _process(delta):
	update_animations()

func update_animations():
	animated_sprite_2d.play("default")
