@tool
@abstract
class_name LogfamiFileBackend
extends RefCounted
## File operations the file sink needs. [LogfamiFsFileBackend] uses the real
## filesystem; [LogfamiMemoryFileBackend] keeps everything in memory for tests.
##
## One backend holds at most one open file at a time.


## Creates [param path] and its parents. True when it exists afterwards.
@abstract func make_dir(path: String) -> bool


@abstract func exists(path: String) -> bool


## Lines in [param path], 0 when it doesn't exist.
@abstract func line_count(path: String) -> int


@abstract func remove(path: String) -> bool


## Moves [param from_path] to [param to_path]. Like on Windows, this fails
## when [param to_path] already exists.
@abstract func rename(from_path: String, to_path: String) -> bool


## Opens [param path] for writing, replacing its content unless
## [param append] is set. Closes a previously opened file.
@abstract func open_file(path: String, append: bool) -> bool


@abstract func write_line(line: String) -> bool


@abstract func flush() -> void


@abstract func close() -> void
