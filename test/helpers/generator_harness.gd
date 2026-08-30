## Drives [TwitchAPIParser] and the two code generators from an in-memory
## OpenAPI spec, with no network and no filesystem access.
##
## The seam this relies on is in [code]TwitchAPIParser.parse_api()[/code]:
##
## [codeblock]
## if definition == {}:
##     definition = await _load_swagger_definition()
## [/codeblock]
##
## Assign [code]definition[/code] up front and the HTTP fetch never happens. Every
## code-generating function downstream is pure [code]String -> String[/code], so
## the whole generator is testable without touching disk. Only
## [code]generate_api()[/code] and [code]write_output_file()[/code] do I/O, and
## this harness never calls them — which also means the [code]const
## api_output_path[/code] pointing at the real
## [code]addons/twitcher/generated/[/code] is never at risk.
##
## Shared deliberately between the test suites and
## [code]test/generator/regenerate_goldens.gd[/code], so a golden file can never
## be produced by a different code path than the one asserting on it.
##
## [b]Lifecycle.[/b] The parser and generators are Nodes, and the parser creates a
## [code]BufferedHTTPClient[/code] in a variable initialiser that is never added
## to the tree. Call [method dispose] or they leak as orphans.
##
## [codeblock]
## var harness := GeneratorHarness.new()
## await harness.build_api(spec)
## var code := harness.code_for("SampleUser")
## harness.dispose()
## [/codeblock]
class_name GeneratorHarness
extends RefCounted

## Which generator to drive. The two are ~90% duplicated forks of each other and
## differ in ways worth testing, so the harness can build either.
enum Flavour { API, EVENTSUB }

var parser: TwitchAPIParser
var generator: Variant
var flavour: Flavour = Flavour.API

var _disposed := false


## Parses [param spec] and prepares components using the API generator.
func build_api(spec: Dictionary) -> void:
	await _build(spec, Flavour.API)


## Parses [param spec] and prepares components using the EventSub generator.
func build_eventsub(spec: Dictionary) -> void:
	await _build(spec, Flavour.EVENTSUB)


func _build(spec: Dictionary, which: Flavour) -> void:
	flavour = which
	parser = TwitchAPIParser.new()
	# Duplicated so a test mutating its own fixture cannot bleed into another
	# test that loaded the same file.
	parser.definition = spec.duplicate(true)

	generator = TwitchAPIGenerator.new() if which == Flavour.API else TwitchEventsubGenerator.new()
	generator.parser = parser

	await parser.parse_api()

	# generate_api() would write to disk; this is the half of it that matters,
	# lifted out so component naming and grouping still happen.
	for component: TwitchGenComponent in parser.components:
		generator.prepare_component(component)


## Generated source for one top-level output file, keyed the way
## [code]grouped_files[/code] keys it: the schema name with any
## [code]Response[/code] / [code]Body[/code] / [code]Opt[/code] suffix stripped,
## lowercased.
##
## Returns [code]""[/code] and pushes an error for an unknown key, rather than
## crashing, so a test failure reports as a missing file instead of a null deref.
func code_for(base_name: String) -> String:
	var key := base_name.to_lower()
	if not generator.grouped_files.has(key):
		push_error("No generated file for '%s'. Available: %s" % [
			key, ", ".join(PackedStringArray(generator.grouped_files.keys()))
		])
		return ""
	var component: Variant = generator.grouped_files[key]
	if component is TwitchAPIGenerator.GroupedComponent \
			or component is TwitchEventsubGenerator.GroupedComponent:
		return generator.group_code(component)
	return generator.component_code(component, 0)


## Generated source for the whole [code]TwitchAPI[/code] facade — the header plus
## one method per operation. API flavour only; the EventSub generator emits no
## methods.
func api_code() -> String:
	var code: String = TwitchAPIGenerator.twitch_api_header
	for method: TwitchGenMethod in parser.methods:
		code += generator.method_code(method)
	return code


## Generated source for a single operation, by [code]operationId[/code].
func method_code(operation_id: String) -> String:
	var method := find_method(operation_id)
	if method == null:
		push_error("No method '%s'" % operation_id)
		return ""
	return generator.method_code(method)


func find_method(operation_id: String) -> TwitchGenMethod:
	for method: TwitchGenMethod in parser.methods:
		if method._name == operation_id:
			return method
	return null


func find_component(classname: String) -> TwitchGenComponent:
	for component: TwitchGenComponent in parser.components:
		if component._classname == classname:
			return component
	return null


## Output file names the generator would have written, sorted for stable
## comparison.
func output_filenames() -> PackedStringArray:
	var names := PackedStringArray()
	for component: Variant in generator.grouped_files.values():
		names.append(component.get_filename())
	names.sort()
	return names


## Frees the Nodes and the parser's orphaned HTTP client. Idempotent.
func dispose() -> void:
	if _disposed:
		return
	_disposed = true

	if parser != null and is_instance_valid(parser):
		# Created in a variable initialiser and only ever added to the tree
		# inside _load_swagger_definition(), which the injected definition
		# skips — so it is an orphan unless freed by hand.
		if parser.client != null and is_instance_valid(parser.client):
			parser.client.free()
		parser.free()
		parser = null

	if generator != null and is_instance_valid(generator):
		(generator as Node).free()
		generator = null
