@tool
extends Resource

## Provides a key to encrypt secrets in the application.
## Please don't store the key in the project,
## otherwise your secrets may revealed easily!
class_name CryptoKeyProvider

static var CRYPTO: Crypto = Crypto.new()

## Folder to the private and public keys
@export_global_file(".key") var encryption_key_path: String = "user://token_encryption.key"
## Godot object to encrypt
var key: CryptoKey = CryptoKey.new()


func _init() -> void:
	_ensure_encryption_key()


func _ensure_encryption_key() -> void:
	if not FileAccess.file_exists(encryption_key_path):
		key = CRYPTO.generate_rsa(4096)
		key.save(encryption_key_path)
		print("On first start a new encryption key was created at: %s \n It is used to encrypt access-, refresh-tokens and client credentials." % encryption_key_path)
	else:
		key.load(encryption_key_path)
