extends Area2D


signal hit
signal try_use_power
signal graze(grazing: bool)

@export var speed = 300
var special_ability_active = false
var max_collision_scale = Vector2(6.5,6.5)

func _ready():
	hide()


func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	$AnimatedSprite2D.animation = "up"  if velocity.y != 0 else "walk"
	scale.y = -1 if velocity.y > 0 else 1
	scale.x = -1 if velocity.x < 0 else 1
	position += velocity * delta
	if Input.is_action_pressed("use_special_ability"):
		try_use_power.emit()
	if special_ability_active:
		var new_scale = $CollisionShape2D.scale + Vector2.ONE * max_collision_scale * delta
		if new_scale < max_collision_scale:
			$CollisionShape2D.scale = new_scale
		else:
			$CollisionShape2D.scale = max_collision_scale
			await get_tree().create_timer(.5).timeout
			special_ability_active = false
		queue_redraw()
	else:
		$CollisionShape2D.scale = Vector2.ONE

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		if special_ability_active:
			body.kill()
		else:
			hide()
			hit.emit()
			$CollisionShape2D.set_deferred("disabled", true)
	elif body.is_in_group("grazing") && !special_ability_active:
		body.get_node("Mob").material.set_shader_parameter("show", true)
		graze.emit(true)


func _on_body_exited(body):
	if body.is_in_group("grazing"):
		body.get_node("Mob").material.set_shader_parameter("show", false)
		graze.emit(false)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func use_special_ability():
	special_ability_active = true


func _draw():
	if special_ability_active:
		draw_circle(Vector2.ZERO,
		$CollisionShape2D.shape.radius * $CollisionShape2D.scale.x,
		Color.GHOST_WHITE)

