@tool
extends Resource

## Provides a key to encrypt secrets in the application.
## Please don't store the key in the project,
## otherwise your secrets may revealed easily!
class_name CryptoKeyProvider

static var CRYPTO: Crypto = Crypto.new()

## Folder to the private and public keys
@export var auth_encryption_cache: String = "user://token_encryption"
## Godot object to encrypt
@export var key: CryptoKey


func _init() -> void:
	_ensure_encryption_key()


func _ensure_encryption_key() -> void:
	if key != null: return
	if not FileAccess.file_exists(auth_encryption_cache + ".key"):
		var key = CRYPTO.generate_rsa(4096)
		key.save(auth_encryption_cache + ".key")
		key.save(auth_encryption_cache + ".pub", true)
		print("On first start a new encryption key was created at: %s \n It is used to encrypt access-, refresh-tokens and client credentials." % auth_encryption_cache)
	key = CryptoKey.new()
	key.load(auth_encryption_cache + ".key")
