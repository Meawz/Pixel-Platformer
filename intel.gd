extends Area2D

func _on_body_entered(body):
	queue_free()
	var intels = get_tree().get_nodes_in_group("Intels")
	if intels.size() == 1:
		Events.level_completed.emit()
