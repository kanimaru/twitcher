extends RefCounted


## Response of the inital device code request

var device_code: String;
var expires_in: int;
var interval: int;
var user_code: String;
var verification_uri: String;

func _init(json: Dictionary):
	device_code = json["device_code"];
	expires_in = int(json["expires_in"]);
	interval = int(json["interval"]);
	user_code = json["user_code"];
	verification_uri = json["verification_uri"];
