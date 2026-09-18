extends Area2D

func _ready():
	$DespawnTimer.start()

# >>> CÓDIGO AÑADIDO / MODIFICADO <<<
func _on_area_entered(area):
	if area.is_in_group("player") or area.has_method("activate_shield"):
		area.activate_shield()
		queue_free()

# >>> CÓDIGO AÑADIDO / MODIFICADO <<<
func _on_despawn_timer_timeout():
	queue_free()
