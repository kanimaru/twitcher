## End-to-end test for [GifReader] over a GIF that fills the LZW code table.
##
## [code]test_lzw.gd[/code] pins the codec directly. This suite covers the path
## that actually broke in the wild: a 7TV emote large enough to reach the 12-bit
## code ceiling would make [method GifReader.load_gif] return a [SpriteFrames]
## whose [code]get_frame_count()[/code] looked healthy while the frame textures
## were empty, so the failure surfaced far away from its cause.
extends TwitcherTest

const FIXTURE := "res://test/fixtures/gif/lzw_full_code_table.gif"
const WIDTH := 160
const HEIGHT := 125


## Regenerates the pixel indices the fixture was built from. Same LCG and seed as
## the generator, so the assertion below is exact rather than a smoke test.
func _expected_indices() -> PackedByteArray:
	var out := PackedByteArray()
	var state := 12345
	for _step: int in WIDTH * HEIGHT:
		state = (state * 1103515245 + 12345) & 0x7FFFFFFF
		out.append((state >> 16) & 0xFF)
	return out


func test_decodes_a_gif_that_fills_the_lzw_code_table() -> void:
	var reader := GifReader.new()
	var frames: SpriteFrames = reader.read(FIXTURE)

	assert_not_null(frames, "fixture missing or unreadable: %s" % FIXTURE)
	if frames == null:
		return
	assert_eq(frames.get_frame_count(&"default"), 1)

	var texture: Texture2D = frames.get_frame_texture(&"default", 0)
	assert_not_null(texture, "a decode that fails mid-frame leaves a null texture")
	if texture == null:
		return

	var image: Image = texture.get_image()
	assert_eq(Vector2i(image.get_width(), image.get_height()), Vector2i(WIDTH, HEIGHT))

	# The fixture's palette is grey ramp (i, i, i), so the red channel of a
	# decoded pixel is the palette index the encoder wrote.
	var expected := _expected_indices()
	var mismatches := 0
	var first_mismatch := ""
	for y: int in HEIGHT:
		for x: int in WIDTH:
			var actual: int = image.get_pixel(x, y).r8
			var want: int = expected[y * WIDTH + x]
			if actual != want:
				mismatches += 1
				if first_mismatch == "":
					first_mismatch = "(%d, %d): got %d, want %d" % [x, y, actual, want]
	assert_eq(mismatches, 0, "pixel mismatches, first at %s" % first_mismatch)
