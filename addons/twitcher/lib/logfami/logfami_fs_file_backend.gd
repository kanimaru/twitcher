@tool
class_name LogfamiFsFileBackend
extends LogfamiFileBackend
## [LogfamiFileBackend] on the real filesystem via [FileAccess] and [DirAccess].

var _file: FileAccess


func make_dir(path: String) -> bool:
	if DirAccess.dir_exists_absolute(path):
		return true
	return DirAccess.make_dir_recursive_absolute(path) == OK


func exists(path: String) -> bool:
	return FileAccess.file_exists(path)


func line_count(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var text: String = FileAccess.get_file_as_string(path)
	if text == "":
		return 0
	var count: int = text.count("\n")
	if not text.ends_with("\n"):
		count += 1
	return count


func remove(path: String) -> bool:
	return DirAccess.remove_absolute(path) == OK


func rename(from_path: String, to_path: String) -> bool:
	if FileAccess.file_exists(to_path):
		return false
	return DirAccess.rename_absolute(from_path, to_path) == OK


func open_file(path: String, append: bool) -> bool:
	close()
	if append and FileAccess.file_exists(path):
		_file = FileAccess.open(path, FileAccess.READ_WRITE)
		if _file != null:
			_file.seek_end()
	else:
		_file = FileAccess.open(path, FileAccess.WRITE)
	return _file != null


func write_line(line: String) -> bool:
	if _file == null:
		return false
	return _file.store_line(line)


func flush() -> void:
	if _file != null:
		_file.flush()


func close() -> void:
	if _file != null:
		_file.close()
		_file = null
