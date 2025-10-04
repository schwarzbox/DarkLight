extends Window

const TITlE_FONT_SIZE: int = 28
const LABEL_FONT_SIZE: int = 20
const CONTAINER_SEPARATION: int = 24
const PARAGRAPH_SEPARATION: int = 4
const BG_COLOR: Color = Color("2e2e35")
const SELECTION_COLOR: Color = Color("476287")

func _ready() -> void:
	size = Vector2i(568, 448)
	# initial state visible = false
	visible = false
	unresizable = true
	always_on_top = true
	popup_window = true
	minimize_disabled = true
	maximize_disabled = true
	# set when visible = false
	force_native = true

	# setup
	$ColorRect.color = BG_COLOR
	$VBoxContainer.alignment = VBoxContainer.ALIGNMENT_CENTER
	$VBoxContainer.add_theme_constant_override("separation", CONTAINER_SEPARATION)
	$VBoxContainer/TextureRect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_CENTERED
	for label: RichTextLabel in [$VBoxContainer/Title, $VBoxContainer/Version, $VBoxContainer/Copyright]:
		label.bbcode_enabled = true
		label.fit_content = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_OFF
		label.context_menu_enabled = false
		label.shortcut_keys_enabled = true
		label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
		label.meta_underlined = true
		label.selection_enabled = true
		label.drag_and_drop_selection_enabled = false
		label.add_theme_color_override("selection_color", SELECTION_COLOR)
		label.add_theme_constant_override("paragraph_separation", PARAGRAPH_SEPARATION)
		label.add_theme_font_override("normal_font", FontFile.new())
		label.add_theme_font_size_override("normal_font_size", LABEL_FONT_SIZE)
		label.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	$VBoxContainer/Title.add_theme_font_override("bold_font", FontFile.new())
	$VBoxContainer/Title.add_theme_font_size_override("bold_font_size", TITlE_FONT_SIZE)

	# populate
	var icon_path: String = ProjectSettings.get_setting("application/config/icon")
	$VBoxContainer/TextureRect.texture = load(icon_path)
	$VBoxContainer/Title.text = "[b]%s[/b]" % ProjectSettings.get_setting("application/config/name")

	var version: String = ProjectSettings.get_setting("application/config/version")
	$VBoxContainer/Version.text = "Version {version}".format({"version": version})

	var godot_copyright: Array[String] = [
		"© {year} Aliaksandr Veledzimovich",
		"veledz@gmail.com",
		"© 2014-{year} Godot Engine contributors",
		"© 2007-2014 Juan Linietsky, Ariel Manzur",
		"[url=https://godotengine.org]https://godotengine.org[/url]"
	]
	$VBoxContainer/Copyright.text = "\n".join(godot_copyright).format(
		{"year": Time.get_date_dict_from_system().year}
	)
	print($VBoxContainer.size)

func _on_godot_copyright_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
