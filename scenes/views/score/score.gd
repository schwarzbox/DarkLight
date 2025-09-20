extends View


func _ready() -> void:
	_start()

func _start() -> void:
	var game_time: int = Globals.SCORES.get_game_time()
	if game_time > 0:
		$CanvasLayer/ScoreContainer/VBoxContainer/LastScore.show()
		$CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.show()
		$CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.grab_focus()
		$CanvasLayer/ScoreContainer/VBoxContainer/LastScore.text = str(game_time)
		$CanvasLayer/ScoreContainer/VBoxContainer/Back.disabled = true
	else:
		$CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.focus_mode = Control.FOCUS_NONE
		$CanvasLayer/ScoreContainer/VBoxContainer/LastScore.hide()
		$CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.hide()
		$CanvasLayer/ScoreContainer/VBoxContainer/Back.disabled = false

	var score_entries: Dictionary = Globals.SCORES.get_scores()
	var score_keys: Array = score_entries.keys()
	score_keys.reverse()

	# show 10 best scores
	var rows: Array[Node] = $CanvasLayer/ScoreContainer/VBoxContainer/Columns/Rows.get_children()
	var rows_size: int = rows.size()
	var row_index: int = 0
	while row_index < rows_size:
		if score_keys:
			var last_score: int = score_keys.pop_back()
			var last_names: Array = score_entries[last_score]
			for last_name: String in last_names:
				if row_index >= rows_size:
					break
				var row: HBoxContainer = rows[row_index]
				row.get_node("Name").text = last_name
				row.get_node("Time").text = str(last_score)
				row.show()
				row_index += 1
		else:
			rows[row_index].hide()
			row_index += 1


func _on_name_edit_text_changed(new_text: String) -> void:
	var caret_column: int = $CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.caret_column
	$CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.text = new_text.to_upper()
	$CanvasLayer/ScoreContainer/VBoxContainer/NameEdit.caret_column = caret_column

func _on_name_edit_text_submitted(new_text: String) -> void:
	if !new_text:
		return

	Globals.SCORES.set_score(new_text)
	# show score
	_start()

func _on_back_pressed() -> void:
	_set_transition(view_exited.emit, self)
