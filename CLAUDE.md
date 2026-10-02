# Twitcher

Godot 4.7 addon for Twitch integration. Source lives in `addons/twitcher/`,
tests in `test/` (GUT 9.7.1, see `test/README.md`).

## GDScript style

Twitcher follows the official GDScript style guide precisely:
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html

Project rules that are stricter than the guide:

- **Never use `:=`.** Always declare concrete types explicitly, for variables,
  constants, parameters and return values:
  `var direction: Vector3 = Vector3(1, 2, 3)`, not `var direction := Vector3(1, 2, 3)`.
- Every function has an explicit return type, including `-> void`.
- Prefer typed containers (`Array[String]`, `Dictionary[String, int]`) where the
  element type is known.

Highlights from the guide that are easy to miss:

- File order: `@tool` → `class_name` → `extends` → `##` doc comment → signals →
  enums → constants → static vars → `@export` vars → vars → `@onready` vars →
  `_static_init()` → static methods → virtual methods → public → private →
  inner classes. Public before private.
- Tabs, lines under 100 characters, continuation lines indented twice.
- Two blank lines between functions, one statement per line (no `if x: y`).
- `and` / `or` / `not` instead of `&&` / `||` / `!`.
- Trailing comma in multi-line arrays, dictionaries and enums; enum members one
  per line; enum names singular PascalCase.
- Private members and methods start with `_`.

When editing existing files, reformat only the lines you touch.

## Architecture

- Modules under `addons/twitcher/lib/` (`http`, `oOuch`, `regex`, …) are
  standalone and must never reference Twitcher classes. They receive logging via
  `set_logger(error, info, debug)` callables.
- Twitcher logging goes through `TwitchLogger` → `TwitchLoggerManager` →
  handlers (`Callable(record: Dictionary)`). The record contract is documented in
  `addons/twitcher/logger/twitch_log_record.gd`.
- `lib/logfami/` is a standalone logging library (file, stdout, formats,
  redaction). Only `TwitchLogfamiBridge` and `TwitchLogSettings` connect Twitcher
  to it; a test fails if Logfami references Twitcher.

## Tests

```bash
godot --headless --path . --import --quit
GODOT_DISABLE_LEAK_CHECKS=1 godot --headless --path . \
  -s res://addons/gut/gut_cmdln.gd -gdir=res://test/unit,res://test/generator \
  -ginclude_subdirs -gexit
```

Every code change comes with tests. One test script per production script at the
mirrored path under `test/unit/`. Tests extend `TwitcherTest`; any new static
state must be registered in `test/helpers/static_state_guard.gd`.

## Releases

Run the **Release** workflow (Actions → Release → *Run workflow*) with the
version, e.g. `2.6.0`. It writes the version into `addons/twitcher/plugin.cfg`
and `Twitcher.VERSION` (exported games don't ship `plugin.cfg`), runs the
suite, commits, tags and publishes the GitHub release. Don't edit the two
version strings by hand; a test and the **Version guard** workflow fail when
they disagree. The scripts live in `.github/scripts/`.

## Commits

Conventional commits (`feat(logger): …`, `fix(chat): …`, `refactor: …`,
`test: …`, `docs: …`).
