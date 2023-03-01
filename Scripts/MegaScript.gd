extends Control

var effect
var recording
signal new_audio_input
# Define the signal in your node's script
signal prompt_send

var JSONObject = JSON.new()
# Replace YOUR_API_KEY with your OpenAI API key
const API_KEY = "<api-key>"
const API_BASE_URL = "https://api.openai.com/v1/edits "

signal new_enviroment_from_chatgpt

var jsonText = {
  "avatar":{
	"gender": "male",
	"animation": "maximocom",
	"color": "#FFF"
  },
  "materials": ["Brick","Plaster","Wood"],
  "sky":{
	"name": "sunny" 
  },
  "wall":{
	"visibility": "True",
	"material": "Brick"
  },
  "floor":{
	"visibility": "True",
	"material": "Wood"
  },
  "ceiling":{
	"visibility": "True",
	"material": "Plaster"
  },
}

func _ready():
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)


func upload_audio_to_whisper_api() -> void:
	var file_name = "audio.wav"
#	var file = FileAccess.open('res://%s' %file_name, FileAccess.READ)
	var file_content = FileAccess.get_file_as_bytes('user://%s' %file_name)
	var body = PackedByteArray()
	body.append_array("\r\n--BodyBoundaryHere\r\n".to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"%s\"\r\n" % file_name).to_utf8_buffer())
	body.append_array("Content-Type: image/png\r\n\r\n".to_utf8_buffer())
	body.append_array(file_content)
	body.append_array("\r\n--BodyBoundaryHere--\r\n".to_utf8_buffer())
	var headers = [
		"Content-Type: multipart/form-data; boundary=BodyBoundaryHere",
		"Access-Control-Allow-Origin: *" 
	]
	var error = $HTTPRequest.request_raw("http://localhost:5000/whisper", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
func _on_record_button_pressed():
	if effect.is_recording_active():
		$RecordButton.text = "Record"
		recording = effect.get_recording()
		effect.set_recording_active(false)
		$Status.text = ""
		var save_path = "user://audio.wav"
		recording.save_to_wav(save_path)
		upload_audio_to_whisper_api()
		$Status.text = "Sending To Server"
	else:
		effect.set_recording_active(true)
		$Status.text = "Recording..."
		$RecordButton.text = "Stop"


func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code == HTTPClient.RESPONSE_OK:
		var response = str_to_var(body.get_string_from_utf8())
		print("response", response)
		# Emit the signal
		print(response.results[0].transcript)
		var jsonText = response.results[0].transcript
		$TextEdit.text=jsonText
		emit_signal("new_audio_input", jsonText)
		$Status.text = "Ready"
	elif response_code == HTTPClient.STATUS_DISCONNECTED:
		print("not connected to server")
		$Status.text = "Failed"

func generate_text(prompt: String):
	# Define the request headers with the API key
	var authorization:  = "Authorization: Bearer "  + API_KEY
	var headers = [
		"Content-Type: application/json",
		authorization
	]
	# Define the request body with the prompt and other parameters
	var data = {
		model="code-davinci-edit-001",
		temperature=0.8,
		instruction= prompt,
		input= JSONObject.stringify(jsonText),
		top_p=1.0
	}
	# Send a POST request to the API with the headers and data
	var request_data = JSONObject.stringify(data)
	print(headers)
	print(request_data)
	print(API_BASE_URL)
	$HTTPRequest2.request(API_BASE_URL, headers,HTTPClient.METHOD_POST, request_data)


func _on_http_request_2_request_completed(result, response_code, headers, body):
	# Check if the request was successful
	if response_code != 200:
		print("Error: ", response_code)
		$Status.text = "Error: "+ response_code
		return ""
	# Parse the response JSON and return the generated text
	var string = body.get_string_from_utf8()
	var t = JSON.parse_string(string)
	print( t.choices[0].text)
	# Emit the signal
	jsonText = JSON.parse_string(t.choices[0].text)
	emit_signal("new_enviroment_from_chatgpt", jsonText)
	$Status.text = "Ready"


func _on_execute_button_pressed():
	$Status.text = "Waiting For API"
	generate_text($TextEdit.text)
