## Unit tests for the vendored GIF LZW codec.
##
## This file comes from [url=https://github.com/jegor377/godot-gdgifexporter]gdgifexporter[/url]
## and is the only piece of Twitcher that has to agree, bit for bit, with an
## encoder it does not control. The interesting failures are all boundary
## conditions in the flexible code size, so that is what these tests pin.
extends TwitcherTest

const LZW_SCRIPT := preload("res://addons/twitcher/media/native/gif-lzw/lzw.gd")

var _codec: RefCounted


func before_each() -> void:
	super()
	_codec = LZW_SCRIPT.new()


## A 256-entry palette, which is what every GIF frame Twitcher decodes uses.
func _palette() -> PackedByteArray:
	var colors := PackedByteArray()
	for index: int in 256:
		colors.append(index)
	return colors


## Near-random bytes from a fixed LCG. Incompressible input is the point: a
## smooth gradient finds repeats early and never fills the code table, so it
## would sail past the boundary these tests exist to cover. The seed is fixed so
## a failure is reproducible rather than flaky.
func _noise(count: int) -> PackedByteArray:
	var out := PackedByteArray()
	var state := 12345
	for _step: int in count:
		state = (state * 1103515245 + 12345) & 0x7FFFFFFF
		out.append((state >> 16) & 0xFF)
	return out


func _round_trip(indices: PackedByteArray) -> PackedByteArray:
	var colors := _palette()
	var compressed: Array = _codec.compress_lzw(indices, colors)
	return _codec.decompress_lzw(compressed[0], compressed[1], colors)


func test_round_trips_a_short_stream() -> void:
	var indices := PackedByteArray([1, 1, 1, 2, 2, 3, 1, 1, 1, 2, 2, 3, 4])
	assert_eq(_round_trip(indices), indices)


func test_round_trips_a_stream_that_never_fills_the_code_table() -> void:
	var indices := _noise(2000)
	assert_eq(_round_trip(indices), indices)


## The regression test for the 12-bit ceiling.
##
## GIF89a caps LZW codes at 12 bits, so the code table stops at 4096 entries.
## [code]compress_lzw[/code] has always honoured that — it emits a Clear Code
## rather than adding entry 4096 — but [code]decompress_lzw[/code] used to widen
## straight off its own counter. The decoder trails the encoder by exactly one
## entry, so it hit counter == 4096 while reading the last code before that
## Clear, computed a 13-bit code size, and started reading 13 bits out of a
## stream still written in 12. Every code after that was shifted: a Clear Code
## was mis-detected, the table reset, and the reader then asked for a code past
## the end of it. In the editor that faulted with "Nonexistent function 'add' in
## base 'Nil'"; in a release build [code]decompress_lzw[/code] simply abandoned
## the frame and handed back a short buffer, which failed much later and much
## further away.
##
## 20 000 near-random indices fill and clear the table several times over, so
## this covers the boundary in both directions.
func test_round_trips_a_stream_that_fills_the_code_table() -> void:
	var indices := _noise(20000)
	var restored := _round_trip(indices)
	assert_eq(restored.size(), indices.size(), "decode must not stop short")
	assert_eq(restored, indices)
