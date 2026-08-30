# Twitcher tests

Automated tests for Twitcher, running on [GUT](https://github.com/bitwes/Gut) 9.7.1.

## Running

```bash
# everything
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gexit

# one suite
godot --headless --path . -s res://addons/gut/gut_cmdln.gd \
  -gconfig= -gtest=res://test/unit/lib/test_regex_util.gd -gexit

# one test
godot --headless --path . -s res://addons/gut/gut_cmdln.gd \
  -gunit_test_name=test_remove_scopes_removes_the_named_scope -gexit
```

Settings live in `.gutconfig.json` at the repo root. Command-line flags override
it; `-gconfig=` disables it entirely.

`GODOT_DISABLE_LEAK_CHECKS=1` is worth exporting locally. Godot reports leaked
`ObjectDB` instances at shutdown, and Twitcher's `@tool` scripts trip it on an
otherwise clean run.

You can also run the suite from the editor via the GUT bottom panel — but see
*Headless is canonical* below.

## Layout

```
test/
├── unit/          mirrors addons/twitcher/. No network, no disk, no sleeping.
├── generator/     golden-file tests for the two code generators
├── helpers/       the test kit (see below)
└── fixtures/      captured Twitch payloads, as data files
```

One test script per production script, at the mirrored path. "Does this file
have a test?" should be answerable with `ls`.

## Generator tests

Twitcher ships ~44 000 lines across 289 generated files. Rather than 289 test
scripts that all say the same thing, `test/generator/` tests the two generators
that produce them.

The seam is in `TwitchAPIParser.parse_api()`:

```gdscript
if definition == {}:
    definition = await _load_swagger_definition()
```

Assign `definition` up front and no HTTP happens. Everything downstream is pure
`String -> String`. `GeneratorHarness` wraps this; it never calls
`generate_api()` or `write_output_file()`, so the real
`addons/twitcher/generated/` is never at risk.

Three fixture specs in `golden/` drive it: `spec_minimal` (scalar type mappings,
required fields), `spec_grouped` (Response/Opt grouping, typed and primitive
arrays, inline sub-objects, pagination) and `spec_renamed_fields` (the full
`_update_name` rename table).

When a golden legitimately changes:

```bash
godot --headless --path . -s res://test/generator/regenerate_goldens.gd
```

Then **read the diff**. A golden regenerated without being read turns a
regression into a rubber stamp. The regenerator and the test suite share
`GeneratorHarness`, so a golden can never be produced by a different code path
than the one asserting on it.

`test_golden_files.gd` also asserts that every `.golden` and every `spec_*.json`
on disk is claimed by a case, so a stale file fails the build instead of rotting
quietly.

## The test kit

### `TwitcherTest`

Extend this, not `GutTest`. It gives you:

- **Isolation.** A `StaticStateGuard` snapshots process-global state before each
  test and restores it after.
- **`scratch_dir()` / `scratch_path()`** — unique `user://` paths per test,
  cleaned up automatically. Point `OAuthToken._cache_path`,
  `CryptoKeyProvider.encrpytion_secret_location` and the media loader's
  `cache_*` exports at these rather than letting them write to real locations.
- **`fixture_text()` / `fixture_json()` / `fixture_lines()`** — load from
  `test/fixtures/`, failing with a useful message when a fixture is missing or
  malformed.
- **`assert_has_entries()`** — subset comparison for DTO round-trips.
- **`assert_matches()`** — regex assertion.

If you override `before_each()` or `after_each()`, **call `super()`**. The guard
is installed there.

### `StaticStateGuard`

Twitcher leaks process-global state aggressively — singleton `instance` vars,
static logger callables installed via `set_logger` cascades, a process-wide HTTP
server port registry, static registries that are never cleared, and
`ProjectSettings` keys written as a side effect of constructing any
`TwitchLogger`.

Without the guard, suites pass alone and fail together. It currently protects 17
slots; `test/unit/helpers/test_static_state_guard.gd` asserts that every declared
slot still resolves, so a rename cannot silently disable protection.

Adding a slot: append to `_SLOTS` in `test/helpers/static_state_guard.gd`. Set
`deep = true` for Arrays and Dictionaries, otherwise the snapshot is a live
reference and restoring is a no-op.

## Conventions

- **One behaviour per test**, named as a sentence:
  `test_remove_scopes_ignores_scopes_that_are_not_present`.
- **A regression test carries a doc comment explaining the bug it pins.** Six
  months on, "why does this assert 2 and not 1?" needs to be answerable from the
  test file alone.
- **Pin surprising-but-intentional behaviour too**, with a comment saying so.
  `test_remove_scopes_emits_twice_known_behaviour` is not a bug report, it is a
  decision record.
- **Prefer table-driven tests** via `use_parameters` when the same assertion
  applies to many inputs.
- **Assert against the whole table** where one exists. `SCOPE_MAP` has ~90
  hand-maintained entries; checking key/value consistency across all of them
  catches the next copy-paste error for free.

## Gotchas

**Parameterized tests cannot use `:=`.** `use_parameters()` returns an untyped
`Variant`, and this project has `untyped_declaration` and friends turned up, so
inference fails at parse time and GUT skips the whole script:

```gdscript
func test_thing(params := use_parameters(rows)) -> void:   # parse error
func test_thing(params = use_parameters(rows)) -> void:    # correct
```

**Typed static arrays reject probe values.** `TwitchCommandBase.ALL_COMMANDS` is
`Array[TwitchCommandBase]`, so you cannot push a string into it in a test. Use a
real (autofreed) instance, or pick an untyped container.

**Headless is canonical.** `Engine.is_editor_hint()` gates behaviour in
`twitch_chat.gd`, `twitch_poll_listener.gd`, `twitch_reward_service.gd`,
`twitch_bot.gd`, `TwitchMediaLoader._load_cache()` and
`ImageMagickConverter._create_temp_filename()`. It reports `false` headless and
`true` in the editor panel, so the same suite can take different paths depending
on how you launch it. CI runs headless; treat that as the truth.

**GUT cannot double `static` functions**, or `HTTPRequest` / `WebSocketPeer`.
`INCLUDE_NATIVE` is defeated by static typing, which this codebase uses
throughout. Wrap engine classes in a thin GDScript adapter and double that.

**Inner classes need registering.** `register_inner_classes(Script)` in
`before_all()` before `double()` will work on `TwitchIRC.ParsedMessage`,
`TwitchTags.*`, `TwitchEventsub.Event` and friends.

**`-gexit_on_complete` is not a real flag** despite appearing in several blog
posts. GUT rejects unknown arguments and exits 1, so a typo fails the build with
a green suite. The real flags are `-gexit` and `-gexit_on_success`.

**A new `class_name` needs a reimport before tests can see it.** Adding a helper
with a `class_name` and running the suite immediately gives
`Identifier "X" not declared in the current scope`. Run
`godot --headless --path . --import --quit` first.

**`to_dict()` keeps insertion order; `to_json()` does not.**
`JSON.stringify` defaults to `sort_keys = true`, so serialised payloads are
alphabetical. Deterministic — just not the order you assigned fields in.

**Godot's JSON parser has no integer type.** Every number parses as `float`, so
`JSON.parse_string(dto.to_json())["count"]` is `7.0`, not `7`. Compare against
the JSON string, or against a float.

## Status

This is the harness plus a first slice of coverage. See the coverage plan for the
phased roadmap: pure-logic suites, generator golden-file tests (which cover the
~44k LOC of generated DTOs by testing the two generators instead), then the
seam-dependent and integration tiers.
