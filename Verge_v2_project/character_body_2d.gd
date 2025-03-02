extends CharacterBody2D

# Constants
const SPEED = 100.0  # Snelheid waarmee de vijand beweegt
const GRAVITY = 800.0  # Zwaartekracht
const TURN_DELAY = 1

# Variabelen
var direction: int = -1  # Richting waarin de vijand beweegt (-1 = links, 1 = rechts)
var can_turn: bool = true
var is_dead: bool = false

# Nodes
@onready var sprite = $Sprite2D  # Verwijzing naar het sprite voor visuele effecten

func _ready() -> void:
	add_to_group("Enemy")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# Toepassen van zwaartekracht
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Beweeg vijand in de huidige richting
	velocity.x = direction * SPEED
	$AnimationPlayer.play("run")
	move_and_slide()
	
	if is_on_wall():
		_turn_around()

	sprite.flip_h = direction > 0

func _turn_around() -> void:
	direction *= -1
	
func _death() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	$AnimationPlayer.stop()
	$AnimationPlayer.play("death")
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("_damage"):
		body._damage(self)  # Roep de `_damage()`-functie van de speler aan
		body.take_damage(1)
