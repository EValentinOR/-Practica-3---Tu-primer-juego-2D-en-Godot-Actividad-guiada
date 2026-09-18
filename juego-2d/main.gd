extends Node

@export var mob_scene: PackedScene
# >>> CÓDIGO AÑADIDO / MODIFICADO <<<
@export var shield_scene: PackedScene

var score = 0

func _ready():
	pass
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	# >>> CÓDIGO AÑADIDO / MODIFICADO <<<
	$ShieldTimer.stop()

func new_game():
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	get_tree().call_group("mobs", "queue_free")
	$Music.play()

func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	# >>> CÓDIGO AÑADIDO / MODIFICADO <<<
	# Inicia el primer escudo con una espera aleatoria entre 5 y 10 segundos
	$ShieldTimer.start(randf_range(5.0, 10.0))

func _on_hud_start_game() -> void:
	new_game()

# >>> CÓDIGO AÑADIDO / MODIFICADO <<<
func _on_shield_timer_timeout() -> void:
	if shield_scene:
		var shield = shield_scene.instantiate()
		# Corregido: Forma válida de obtener el tamaño de la ventana en un Node
		var screen_size = get_viewport().get_visible_rect().size
		
		# Genera la posición aleatoria en pantalla
		shield.position = Vector2(
			randf_range(50, screen_size.x - 50),
			randf_range(50, screen_size.y - 50)
		)
		add_child(shield)
	
	# Programa la aparición del PRÓXIMO escudo entre 10 y 20 segundos después
	$ShieldTimer.start(randf_range(10.0, 15.0))
