@tool
extends RefCounted

class_name GifReader

var lzw_module = preload("./gif-lzw/lzw.gd")
var lzw = lzw_module.new()

func read(source_file) -> SpriteFrames:
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return null
	var data = file.get_buffer(file.get_length())
	file.close()
	return load_gif(data)

func load_gif(data):
	var pos = 0
	# Header 'GIF89a'
	pos = pos + 6
	# Logical Screen Descriptor
	var width = get_int(data, pos)
	var height = get_int(data, pos + 2)
	var packed_info = data[pos + 4]
	var background_color_index = data[pos + 5]
	pos = pos + 7
	# Global color table
	var global_lut
	if (packed_info & 0x80) != 0:
		var lut_size = 1 << (1 + (packed_info & 0x07))
		global_lut = get_lut(data, pos, lut_size)
		pos = pos + 3 * lut_size
	# Frames
	var repeat = -1
	var img = Image.new()
	var frame_number = 0
	var frame_delay = -1
	var frame_anim_packed_info = -1
	var frame_transparent_color = -1
	var sprite_frame = SpriteFrames.new()

	img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	while pos < data.size():
		if data[pos] == 0x21: # Extension block
			var ext_type = data[pos + 1]
			pos = pos + 2 # 21 xx ...
			match ext_type:
				0xF9: # Graphic extension
					var subblock = get_subblock(data, pos)
					frame_anim_packed_info = subblock[0]
					frame_delay = get_int(subblock, 1)
					frame_transparent_color = subblock[3]
				0xFF: # Application extension
					var subblock = get_subblock(data, pos)
					if subblock != null and subblock.get_string_from_ascii() == "NETSCAPE2.0":
						subblock = get_subblock(data, pos + 1 + subblock.size())
						repeat = get_int(subblock, 1)
				_: # Miscelaneous extension
					#print("extension ", data[pos + 1])
					pass
			var block_len = 0
			while data[pos + block_len] != 0:
				block_len = block_len + data[pos + block_len] + 1
			pos = pos + block_len + 1
		elif data[pos] == 0x2C: # Image data
			var img_left = get_int(data, pos + 1)
			var img_top = get_int(data, pos + 3)
			var img_width = get_int(data, pos + 5)
			var img_height = get_int(data, pos + 7)
			var img_packed_info = get_int(data, pos + 9)
			pos = pos + 10
			# Local color table
			var local_lut = global_lut
			if (img_packed_info & 0x80) != 0:
				var lut_size = 1 << (1 + (img_packed_info & 0x07))
				local_lut = get_lut(data, pos, lut_size)
				pos = pos + 3 * lut_size
			# Image data
			var min_code_size = data[pos]
			pos = pos + 1
			var colors = []
			for i in range(0, 1 << min_code_size):
				colors.append(i)
			var block = PackedByteArray()
			while data[pos] != 0:
				block.append_array(data.slice(pos + 1, pos + data[pos] + 1))
				pos = pos + data[pos] + 1
			pos = pos + 1
			var decompressed = lzw.decompress_lzw(block, min_code_size, colors)
			var disposal = (frame_anim_packed_info >> 2) & 7 # 1 = Keep, 2 = Clear
			var transparency = frame_anim_packed_info & 1
			if disposal == 2:
				if transparency == 0 and background_color_index != frame_transparent_color:
					img.fill(local_lut[background_color_index])
				else:
					img.fill(Color(0,0,0,0))
			var p = 0
			for y in range(0, img_height):
				for x in range(0, img_width):
					var c = decompressed[p]
					if transparency == 0 or c != frame_transparent_color:
						img.set_pixel(img_left + x, img_top + y, local_lut[c])
					p = p + 1
			var frame = ImageTexture.create_from_image(img);
			sprite_frame.add_frame(&"default", frame, frame_delay / 100.0);
			frame_anim_packed_info = -1
			frame_transparent_color = -1
			frame_delay = -1
			frame_number = frame_number + 1
		elif data[pos] == 0x3B: # Trailer
			pos = pos + 1
	sprite_frame.set_animation_speed(&"default", 1);
	return sprite_frame

func get_subblock(data: PackedByteArray, pos):
	if data[pos] == 0:
		return null
	else:
		return data.slice(pos + 1, pos + data[pos] + 1)

func get_lut(data, pos, size):
	var colors = Array()
	for i in range(0, size):
		colors.append(Color(data[pos + i * 3] / 255.0, data[pos + 1 + i * 3] / 255.0, data[pos + 2 + i * 3] / 255.0))
	return colors

func get_int(data, pos):
	return data[pos] + (data[pos + 1] << 8)
