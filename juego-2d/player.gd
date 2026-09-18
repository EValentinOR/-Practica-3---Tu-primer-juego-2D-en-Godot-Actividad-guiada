extends Area2D
signal hit
signal lives_changed(current_lives)
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var lives: int = 3
var has_shield: bool = false

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func _on_body_entered(body: Node2D) -> void:
	if has_shield:
		has_shield = false
		$ShieldSprite.hide() # Oculta el aura visual del escudo
		# Desactiva temporalmente la colisión para no recibir daño en el mismo frame
		$CollisionShape2D.set_deferred("disabled", true)
		await get_tree().create_timer(0.5).timeout
		$CollisionShape2D.disabled = false
		return

	# Si no tiene escudo, pierde 1 vida
	lives -= 1
	lives_changed.emit(lives)
	
	if lives <= 0:
		hide()
		hit.emit() # Game Over
		$CollisionShape2D.set_deferred("disabled", true)
		
	else:
		# Invulnerabilidad temporal / Parpadeo al recibir daño
		$CollisionShape2D.set_deferred("disabled", true)
		for i in range(4):
			hide()
			await get_tree().create_timer(0.1).timeout
			show()
			await get_tree().create_timer(0.1).timeout
		$CollisionShape2D.disabled = false
		
func activate_shield():
	has_shield = true
	if has_node("ShieldSprite"):
		$ShieldSprite.show()
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	lives = 3
	has_shield = false
	lives_changed.emit(lives)
