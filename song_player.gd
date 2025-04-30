extends Node3D

@onready var songs := $"."
var song_list: Array[AudioStreamPlayer3D] = []
var current_song: AudioStreamPlayer3D = null
var music_started := false

func _ready():
	
	for child in get_children():
		if child is AudioStreamPlayer3D:
			song_list.append(child)
	
	
	
	
func _process(_delta):
	if Global.globalMusicStart and not music_started:
		music_started = true
		await get_tree().create_timer(3.0).timeout
		play_random_song()


func play_random_song():
	if Global.globalMusicStart:
		if song_list.is_empty():
			
			return

		
		if current_song:
			current_song.stop()

		
		current_song = song_list[randi() % song_list.size()]
		
		current_song.play()

		
		if not current_song.finished.is_connected(_on_song_finished):
			current_song.finished.connect(_on_song_finished)


func _on_song_finished():
	
	play_random_song()
