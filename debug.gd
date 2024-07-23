extends Node


var multiplier = 1


func _ready():
	$Player.show()


func _on_player_graze(grazing):
	if grazing:
		multiplier += 1 if multiplier < 10 else 0
	else:
		multiplier -= 1 if multiplier > 1 else 0
	print(multiplier)


func _on_player_hit():
	print("hit")

