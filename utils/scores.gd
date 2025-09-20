extends Resource

# export is required
@export var scores: Dictionary = {}

var _start_time: int = 0
var _game_time: int = 0

func save_start_time() -> void:
	_start_time = Time.get_ticks_msec()

func save_game_time() -> void:
	_game_time = _game_time + (Time.get_ticks_msec() - _start_time)

func get_game_time() -> int:
	# convert _game_time to seconds
	@warning_ignore("integer_division")
	return int(_game_time) / 1000 if int(_game_time) > 0 else _game_time

func reset_game_time() -> void:
	_game_time = 0

func get_scores() -> Dictionary:
	_load_data()
	return scores

func set_score(text: String) -> void:
	var game_time: int = get_game_time()

	var entry: Array = scores.get(game_time, [])
	entry.append(text)
	scores[game_time] = entry
	scores.sort()

	_save_data()

	reset_game_time()

func _save_data() -> void:
	var result: Error = ResourceSaver.save(self, Globals.SCORES_FILE_PATH)
	assert(result == OK)


func _load_data() -> void:
	if ResourceLoader.exists(Globals.SCORES_FILE_PATH):
		var resource: Resource = ResourceLoader.load(Globals.SCORES_FILE_PATH)
		if resource is Resource:
			scores = resource.scores
