extends Node


@export var mob_scene: PackedScene
var screen_size = Vector2.ZERO
var game_time = 0
var score = 0
var multiplier = 1
var sink_speed = 100
var mob_velocity_ranges = [
	[100.0,150.0],
	[120.0,180.0],
	[140.0,210.0],
	[160.0,240.0],
	[180.0,270.0],
	[200.0,300.0]
]
var mob_velocity_range = mob_velocity_ranges[0]
var mob_velocity_ranges_index = 0
var playing = false


func _ready():
	screen_size = get_viewport().get_visible_rect().size


func _process(delta):
	if playing:
		$Player.position -= Vector2(0.0,-1.0) * sink_speed * delta
	$Player.position = $Player.position.clamp(Vector2.ZERO, screen_size)


func game_over():
	playing = false
	$ScoreTimer.stop()
	$MobTimer.stop()
	$MobTimer.wait_time = 2.0
	$GameTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group("grazing", "queue_free")
	get_tree().call_group("mobs", "queue_free")
	playing = true
	mob_velocity_range = mob_velocity_ranges[0]
	game_time = 0
	score = 0
	$HUD.update_score(score)
	$Music.play()
	$Player.start($StartPosition.position)
	$HUD.show_message("Get Ready")
	$StartTimer.start()


func _on_start_timer_timeout():
	spawn_mob()
	$GameTimer.start()
	$MobTimer.start()
	$ScoreTimer.start()


func _on_score_timer_timeout():
	score += 10 * multiplier
	$HUD.update_score(score)


func spawn_mob():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	#var direction = mob_spawn_location.rotation + PI / 2
	mob.position = mob_spawn_location.position
	var direction = mob.position.angle_to_point($Player.position)
	direction += randf_range(-PI / 8, PI / 8)
	mob.rotation = direction
	var velocity = Vector2(randf_range(
		mob_velocity_range[0],
		mob_velocity_range[1]
	), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)


func _on_mob_timer_timeout():
	spawn_mob()


func multiply_score(grazing):
	if grazing:
		$HUD/PowerUI/PowerButton/PowerGauge.value += 5
		$PowerTimer.start()
		multiplier += .5 if multiplier < 10 else .0
		$HUD/ScoreLabel.set("theme_override_colors/font_color", "#ffd700")
	else:
		$PowerTimer.stop()
		multiplier -= .5 if multiplier > 1 else .0
		$HUD/ScoreLabel.set("theme_override_colors/font_color", "#ffffff")


func _on_game_timer_timeout():
	game_time += 1
	match game_time:
		10, 20, 40, 60:
			$MobTimer.wait_time -= 0.25
		10, 20, 40, 60, 100:
			mob_velocity_ranges_index += 1
			mob_velocity_range = mob_velocity_ranges[mob_velocity_ranges_index]
		100:
			$MobTimer.wait_time -= 0.5
			$GameTimer.stop()


func _on_hud_input_submit(player_name):
	var file_access_mode = FileAccess.WRITE_READ
	if FileAccess.file_exists("user://dodge_the_creeps_scores.txt"):
		file_access_mode = FileAccess.READ_WRITE
	var file = FileAccess.open("user://dodge_the_creeps_scores.txt", file_access_mode)
	file.seek_end()
	file.store_string("%s: %s\n" % [player_name, score])
	var scores = Array(file.get_as_text().split("\n"))
	scores.sort_custom(func(a, b): return int(a.substr(a.find(":") + 1)) > int(b.substr(b.find(":") + 1)))
	$HUD.show_leaderboard("\n".join(scores.slice(0, 3)))



func _on_power_timer_timeout():
	$HUD/PowerUI/PowerButton/PowerGauge.value += 5 * multiplier


func _on_hud_use_power():
	$Player.use_special_ability()
	$HUD/PowerUI/PowerButton/PowerGauge.value = 0
