extends RigidBody2D


func _on_mob_mob_destroyed():
	queue_free()

