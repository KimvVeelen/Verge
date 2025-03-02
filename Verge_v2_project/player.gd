extends CharacterBody2D

# Constants
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0

# States
enum State { IDLE, RUN, JUMP, CROUCH, ATTACK, INTERACT }
var current_state: State = State.IDLE

# Variables
var can_attack = true
var interact_target = null  # Object waarmee de speler kan interacteren
var is_invincible = false
var knockback_force = 200.0
var invincibility_time = 1.0
var blink_interval = 0.1
var lives: int = 3

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var life_label = $Lifelabel

func _ready() -> void:
	add_to_group("Player")
	_update_life_label()
	

func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_update_state()
	_apply_gravity(delta)
	_move_player(delta)

func _handle_input(delta: float) -> void:
	# Springen
	if Input.is_action_just_pressed("jump") and is_on_floor() and current_state != State.CROUCH:
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMP

	# Aanvallen
	elif Input.is_action_just_pressed("attack") and current_state != State.CROUCH and current_state == State.IDLE:
		_attack()

	# Interactie met omgeving
	elif Input.is_action_just_pressed("interact") and interact_target:
		_interact_with_environment()

	# Bukken
	elif Input.is_action_pressed("ui_down") and is_on_floor():
		current_state = State.CROUCH
	elif Input.is_action_just_released("crouch") and current_state == State.CROUCH:
		current_state = State.IDLE

	# Lopen of rennen
	elif Input.get_axis("ui_left", "ui_right") != 0 and is_on_floor() and current_state != State.CROUCH:
		current_state = State.RUN

	# Stilstaan
	elif is_on_floor() and current_state != State.ATTACK:
		current_state = State.IDLE

func _update_state() -> void:
	match current_state:
		State.IDLE:
			animation_player.play("idle")
		State.RUN: 
			velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
			animation_player.play("run")
			if Input.get_axis("ui_left", "ui_right") == 0:
				current_state = State.IDLE
		State.JUMP:
			animation_player.play("jump")
			if animation_player.current_animation_position >= animation_player.get_current_animation_length() - 0.05:
				animation_player.pause()
		State.CROUCH:
			velocity.x = 0
			animation_player.play("crouch")
		State.ATTACK:
			animation_player.play("attack")
		State.INTERACT:
			animation_player.play("interact")

func _apply_gravity(delta: float) -> void:
	# Zwaartekracht toepassen als de speler niet op de grond staat
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _move_player(delta: float) -> void:
	# Speler horizontaal besturen tijdens sprong of beweging
	if current_state != State.CROUCH:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			velocity.x = direction * SPEED
			sprite.scale.x = 1 if direction > 0 else -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 5 * delta)
		
	move_and_slide()

func _attack() -> void:
	current_state = State.ATTACK
	animation_player.play("attack")
	await animation_player.animation_finished
	current_state = State.IDLE

func _interact_with_environment() -> void:
	if interact_target:
		interact_target.trigger()  # Vereist dat het object een `trigger()`-methode heeft
	current_state = State.INTERACT

# Detecteer interacties
func _on_Area2D_body_entered(body: Node) -> void:
	if body.has_method("trigger"):
		interact_target = body

func _on_Area2D_body_exited(body: Node) -> void:
	if body == interact_target:
		interact_target = null

func _on_weapon_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		var enemy = body
		enemy._death()
		print("body geraakt.")

func _damage(enemy: Node2D) -> void:

	if is_invincible:
		return  # Speler is tijdelijk onkwetsbaar
	# Knockback toepassen
	var direction = (global_position - enemy.global_position).normalized()
	velocity += direction * knockback_force

	# Onkwetsbaarheid en knipperen
	is_invincible = true
	_start_blinking()
	await _wait(invincibility_time)
	is_invincible = false
	modulate = Color(1, 1, 1, 1)  # Herstel zichtbaarheid volledig

func _start_blinking() -> void:
	var blink_time = 0.0
	while blink_time < invincibility_time:
		visible = !visible
		await _wait(blink_interval)
		blink_time += blink_interval
	visible = true

func _wait(duration: float) -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.start(duration)
	await timer.timeout
	timer.queue_free()

func take_damage(amount: int) -> void:
	# Verminder levens
	lives -= amount
	if lives <= 0:
		_player_died()
	else:
		_update_life_label()

func _update_life_label() -> void:
	# Werk het label bij
	life_label.text = str(lives)

func _player_died() -> void:
	# Verwerk het einde van het spel
	get_tree().change_scene_to_file("res://game_over.tscn")


func _on_health_component_death() -> void:
	pass # Replace with function body.
