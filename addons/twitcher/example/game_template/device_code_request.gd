extends Window

@onready var preamble: RichTextLabel = %Preamble
@onready var code: Label = %Code
@onready var confirm: Button = %Confirm

var _device_code_request: OAuth.OAuthDeviceCodeResponse

func _ready() -> void:
	preamble.meta_clicked.connect(open_os_browser.unbind(1))
	confirm.pressed.connect(open_os_browser)
	close_requested.connect(queue_free)


func open_request(device_code_request: OAuth.OAuthDeviceCodeResponse) -> void:
	_device_code_request = device_code_request
	code.text = device_code_request.user_code
	popup_centered()


func close() -> void:
	close_requested.emit()


func open_os_browser() -> void:
	OS.shell_open(_device_code_request.verification_uri)
