extends Resource

var scores: Dictionary = {}

func get_scores() -> Dictionary:
	_load_data()
	return scores

func set_score(time: int, text: String) -> void:
	var entry: Array = scores.get(time, [])
	entry.append(text)
	scores[time] = entry
	scores.sort()

	_save_data()

func _save_data() -> void:
	var result: Error = ResourceSaver.save(self, Globals.SCORES_FILE_PATH)
	assert(result == OK)


func _load_data() -> void:
	if ResourceLoader.exists(Globals.SCORES_FILE_PATH):
		var resource: Resource = ResourceLoader.load(Globals.SCORES_FILE_PATH)
		if resource is Resource:
			scores = resource.scores
