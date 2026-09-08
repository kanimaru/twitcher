# GIF fixtures

## `lzw_full_code_table.gif`

160x125, one frame, 256-entry greyscale global colour table, no transparency.

Generated rather than captured. The pixel indices come from the LCG
`state = (state * 1103515245 + 12345) & 0x7FFFFFFF`, seeded at `12345`, taking
`(state >> 16) & 0xFF` — 20 000 near-random bytes. Incompressible input is the
whole point: a real-world image finds repeats early and never fills the LZW code
table, which is why this bug survived until a 318-frame 7TV emote hit it
(issue #132). The stream was then encoded by Twitcher's own `compress_lzw`, so
it is a stream the codebase must be able to read back.

It is a valid GIF89a — Pillow decodes it and reproduces the index stream exactly.
Decoding it drives the LZW code table to its full 4096 entries and back through
six mid-stream Clear Codes, which is the boundary
`decompress_lzw` used to mishandle.

`test_gif_reader.gd` regenerates the index stream from the same LCG, so the
fixture and its expected output cannot drift apart.
