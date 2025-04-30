extends RichTextLabel

func _ready() -> void:
	update_countdown()

func update_countdown() -> void:
	var release_date_dict := {
		"year": 2025,
		"month": 9,
		"day": 10,
		"hour": 0,
		"minute": 0,
		"second": 0
	}

	var release_unix := Time.get_unix_time_from_datetime_dict(release_date_dict)
	var current_unix := Time.get_unix_time_from_system()

	var seconds_remaining := release_unix - current_unix
	var days_remaining := int(seconds_remaining / 86400.0)  # 86400 seconds in a day

	clear()
	if days_remaining > 0:
		append_text("[center][b]" + str(days_remaining) + " day(s) left until Nod Krai![/b][/center]")
	elif days_remaining == 0:
		append_text("[center][b]Nod Krai releases today![/b][/center]")
	else:
		append_text("[center][b]Nod Krai has already released.[/b][/center]")
