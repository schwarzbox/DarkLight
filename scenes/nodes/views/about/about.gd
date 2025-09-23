extends Window


func _ready() -> void:
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
	var font: FontFile = FontFile.new()
	$VBoxContainer/TextureRect.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_CENTERED
	for label: Label in [$VBoxContainer/Title, $VBoxContainer/Version, $VBoxContainer/Copyright]:
		label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
		label.add_theme_constant_override("line_spacing", 4)
		label.add_theme_font_override("font", font)

	$VBoxContainer/Title.add_theme_font_size_override("font_size", 32)
	$VBoxContainer/Title.uppercase = true
	$VBoxContainer/Version.add_theme_font_size_override("font_size", 24)
	$VBoxContainer/Copyright.add_theme_font_size_override("font_size", 24)

	# setup rich label
	$VBoxContainer/GodotCopyright.bbcode_enabled = true
	$VBoxContainer/GodotCopyright.fit_content = true
	$VBoxContainer/GodotCopyright.scroll_active = false
	$VBoxContainer/GodotCopyright.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_OFF
	$VBoxContainer/GodotCopyright.context_menu_enabled = false
	$VBoxContainer/GodotCopyright.shortcut_keys_enabled = false
	$VBoxContainer/GodotCopyright.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	$VBoxContainer/GodotCopyright.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	$VBoxContainer/GodotCopyright.meta_underlined = true
	$VBoxContainer/GodotCopyright.add_theme_constant_override("paragraph_separation", 4)
	$VBoxContainer/GodotCopyright.add_theme_font_override("normal_font", font)
	$VBoxContainer/GodotCopyright.add_theme_font_size_override("normal_font_size", 24)

	# populate
	var icon_path: String = ProjectSettings.get_setting("application/config/icon")
	$VBoxContainer/TextureRect.texture = load(icon_path)
	$VBoxContainer/Title.text = ProjectSettings.get_setting("application/config/name")
	var version: String = ProjectSettings.get_setting("application/config/version")
	$VBoxContainer/Version.text = "Version {version}".format({"version": version})

	var copyright: Array[String] = [
		"© {year} Aliaksandr Veledzimovich",
		"veledz@gmail.com",
	]
	$VBoxContainer/Copyright.text = "\n".join(copyright).format(
		{"year": Time.get_date_dict_from_system().year}
	)

	var godot_copyright: Array[String] = [
		"© 2014-present Godot Engine contributors",
		"© 2007-2014 Juan Linietsky, Ariel Manzur",
		"[url=https://godotengine.org]https://godotengine.org[/url]",
		"[url=https://godotengine.org/license]LICENSE[/url]"
	]
	$VBoxContainer/GodotCopyright.text = "\n".join(godot_copyright)


func _on_godot_copyright_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
