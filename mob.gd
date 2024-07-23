extends CharacterBody2D


signal mob_destroyed


func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])


func kill():
	mob_destroyed.emit()


func _on_visible_on_screen_notifier_2d_screen_exited():
	kill()

