extends Node
	
func play_audio(path: String, audio: AudioStreamPlayer3D = null):
	if audio == null:
		audio = AudioStreamPlayer3D.new()
	audio.autoplay = true
	audio.stream = AudioStreamOggVorbis.load_from_file(path)
	audio.finished.connect(despawn_callback(audio))
	get_tree().get_root().add_child(audio)

func despawn_callback(node: Node) -> Callable:
	return func ():
		node.queue_free()
