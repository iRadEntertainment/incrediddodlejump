# platform.gd
class_name OSPlatform

enum Type {
	DESKTOP,
	ANDROID,
	IOS,
	WEB,
	WEB_ANDROID,
	WEB_IOS
}

static var platform_type: Type


static func _static_init() -> void:
	platform_type = _detect_platform()


static func _detect_platform() -> Type:
	if OS.has_feature("web_android"): return Type.WEB_ANDROID
	if OS.has_feature("web_ios"): return Type.WEB_IOS
	if OS.has_feature("android"): return Type.ANDROID
	if OS.has_feature("ios"): return Type.IOS
	if OS.has_feature("web"): return Type.WEB
	return Type.DESKTOP
