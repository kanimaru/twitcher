extends Resource
class_name OAuthSetting

const OAuthHTTPClient = preload("./http_client.gd")

## What is the redirect port
@export var redirect_url: String = "http://localhost:7170"
## Wellknown endpoint
@export var well_known_url: String
## Path where tokens can be get
@export var token_url: String
## Path to the authorization endpoint
@export var authorization_url: String
## Path to the device code flow URL.
@export var device_authorization_url: String
## Where should the tokens be cached
@export var cache_file: String = "res://auth.key"
## Key to encrypt the token cache
@export var encryption_secret: String
## Client ID to authorize
@export var client_id: String
## Client Secret to authorize (optional depending on flow)
@export var client_secret: String
## Defines the authorization flow.
@export var authorization_flow: OAuth.AuthorizationFlow
## All requested scopes (either Array[String] or space separated string)
@export var scopes: Array[String]

var well_known_setting: Dictionary

var url_regex = RegEx.create_from_string("((https?://)?([^:/]+))(:([0-9]+))?(/.*)?")

func load_from_wellknown(wellknow_url: String) -> void:
	var matches = url_regex.search(wellknow_url)
	var url = matches.get_string(1)
	var port = matches.get_string(5)
	if port == "": port = -1
	var path = matches.get_string(6)
	var http_client = OAuthHTTPClient.new(url, port)
	var request = http_client.request(path, HTTPClient.METHOD_GET, OAuthHTTPClient.HEADERS, "")
	var response = await http_client.wait_for_request(request) as OAuthHTTPClient.ResponseData
	var json = JSON.parse_string(response.response_data.get_string_from_utf8())
	token_url = json["token_endpoint"]
	authorization_url = json["authorization_endpoint"]
	device_authorization_url = json.get("device_authorization_endpoint", "")
	well_known_setting = json
	
func get_token_host() -> String:
	var matches = url_regex.search(token_url)
	if matches == null: return ""
	return matches.get_string(1)
	
func get_token_path() -> String:
	var matches = url_regex.search(token_url)
	if matches == null: return ""
	return matches.get_string(6)
	
func get_authorization_host() -> String:
	var matches = url_regex.search(authorization_url)
	if matches == null: return ""
	return matches.get_string(1)
	
func get_authorization_path() -> String:
	var matches = url_regex.search(authorization_url)
	if matches == null: return ""
	return matches.get_string(6)
	
func get_device_authorization_host() -> String:
	var matches = url_regex.search(device_authorization_url)
	if matches == null: return ""
	return matches.get_string(1)
	
func get_device_authorization_path() -> String:
	var matches = url_regex.search(device_authorization_url)
	if matches == null: return ""
	return matches.get_string(6)
	
func get_redirect_path() -> String:
	var matches = url_regex.search(redirect_url)
	if matches == null: return ""
	var path = matches.get_string(6)
	return path if path != "" else "/"
	
func get_redirect_port() -> int:
	var matches = url_regex.search(redirect_url)
	if matches == null: return 7170
	var port = matches.get_string(5)
	if port == "": return 7170 # Default cause nothing was defined
	return int(port)
	
func get_scopes():
	return " ".join(scopes)
