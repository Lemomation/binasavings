extends RichTextLabel

const REMOTE_URL = "https://realsavings-8a9f0.web.app/date.json"
@onready var firebase_request: HTTPRequest = $"../ProgressBar/PROGREss label2/Firebase Request"

var fallback_release_date := {
	"year": 2025,
	"month": 9,
	"day": 10,
	"hour": 0,
	"minute": 0,
	"second": 0
}
var fallback_game_title = "Columbina" # Default title

func _ready() -> void:
	firebase_request.request_completed.connect(_on_firebase_request_completed)
	firebase_request.request(REMOTE_URL)

func _on_firebase_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var fetched_release_date: Dictionary
	var fetched_game_title: String

	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var json_string = body.get_string_from_utf8()
		var data = JSON.parse_string(json_string)
		if typeof(data) == TYPE_DICTIONARY and data.has("release_date") and data.has("game_title"):
			fetched_release_date = data.release_date
			fetched_game_title = data.game_title
			update_countdown(fetched_release_date, fetched_game_title)
			return # Successfully retrieved from Firebase
		else:
			printerr("Error: Invalid JSON data received from Firebase.")
	else:
		printerr("Error retrieving data from Firebase. Result:", result, "Response Code:", response_code)

	# Fallback to local data if Firebase retrieval fails or data is invalid
	update_countdown(fallback_release_date, fallback_game_title)

func update_countdown(release_date_data: Dictionary, game_title: String) -> void:
	var release_unix := Time.get_unix_time_from_datetime_dict(release_date_data)
	var current_unix := Time.get_unix_time_from_system()

	var seconds_remaining := release_unix - current_unix
	var days_remaining := int(seconds_remaining / 86400.0) # 86400 seconds in a day

	clear()
	if days_remaining > 0:
		append_text("[center][b]" + str(days_remaining) + " day(s) left until " + game_title + "![/b][/center]")
	elif days_remaining == 0:
		append_text("[center][b]" + game_title + " releases today![/b][/center]")
	else:
		append_text("[center][b]" + game_title + " has already released.[/b][/center]")
