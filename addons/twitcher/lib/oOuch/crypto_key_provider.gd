@icon("./security-icon.svg")
@tool
extends Resource

## Provides a key to encrypt secrets in the application.
## Please don't store the key in the project,
## otherwise your secrets may revealed easily!
class_name CryptoKeyProvider

## Identify oOuch library specifics without collisions
const _CONFIG_PACKAGE_KEY: String = "dev.kani.oouch"
const _CONFIG_SECRET_KEY: String = "encryption"
const _AES_BLOCK_SIZE : int = 16

## Location of the encryption secrets
@export_global_file var encrpytion_secret_location: String = "user://encryption_key.cfg"

static var aes: AESContext = AESContext.new()

## To prevent accidental spoiler in the debugger
class KeyData extends RefCounted:
	var key: String

var current_key_data: KeyData

func _init() -> void:
	# Call defered cause the setter of encrpytion_secret_location isn't set otherwise
	_get_encryption_secret.call_deferred()
	
	
## Don't cache it in a variable so that you accidently leak your secret when you debug
func _get_encryption_secret() -> String:
	if is_instance_valid(current_key_data):
		return current_key_data.key
		
	var config = ConfigFile.new()
	var error = config.load(encrpytion_secret_location)
	if error == ERR_FILE_NOT_FOUND:
		_create_secret(config)
	elif error != OK:
		printerr("Can't open %s cause of %s" % [encrpytion_secret_location, error_string(error)])
		return ""
	
	var key: String = config.get_value(_CONFIG_PACKAGE_KEY, _CONFIG_SECRET_KEY, "")
	if key == "":
		key = _create_secret(config)
		
	current_key_data = KeyData.new()
	current_key_data.key = key
	return key


func _create_secret(config: ConfigFile) -> String:
	print("Creating a new secret for encryption you can find it %s" % encrpytion_secret_location)
	var crypto : Crypto = Crypto.new()

	var secret_data : PackedByteArray = crypto.generate_random_bytes(16)
	var secret : String = secret_data.hex_encode()
	config.set_value(_CONFIG_PACKAGE_KEY, _CONFIG_SECRET_KEY, secret)
	var err = config.save(encrpytion_secret_location)
	if err != OK: push_error("Couldn't save encryption key cause of ", error_string(err))
	return secret
	
	
func _pad(value: PackedByteArray) -> PackedByteArray:
	var pad_len : int = _AES_BLOCK_SIZE - (value.size() % _AES_BLOCK_SIZE)
	for i in range(pad_len):
		value.append(pad_len)
	return value


func _unpad(value: PackedByteArray) -> PackedByteArray:
	if value.is_empty():
		return value
	var pad_len : int = value[-1]
	if pad_len <= 0 or pad_len > _AES_BLOCK_SIZE or value.size() < pad_len:
		push_error("Invalid padding detected (%s)" % pad_len)
		return PackedByteArray()
	return value.slice(0, -pad_len)


func encrypt(value: PackedByteArray) -> PackedByteArray:
	var padded_value = _pad(value)
	aes.start(AESContext.MODE_ECB_ENCRYPT, _get_encryption_secret().to_utf8_buffer())
	var encrypted_value: PackedByteArray = aes.update(padded_value)
	aes.finish()
	return encrypted_value


func decrypt(value: PackedByteArray) -> PackedByteArray:
	aes.start(AESContext.MODE_ECB_DECRYPT, _get_encryption_secret().to_utf8_buffer())
	var decrypted_value: PackedByteArray = aes.update(value)
	aes.finish()
	return _unpad(decrypted_value)
