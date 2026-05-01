# platform.gd
class_name OSPlatform

enum Type {
	WINDOWS,
	MACOS,
	LINUX,
	ANDROID,
	IOS,
	WEB_ANDROID,
	WEB_IOS,
	OTHER,
}
enum Host {
	PC,
	MOBILE,
	WEB,
	OTHER,
}

static var type: Type
static var host: Host


static func _static_init() -> void:
	type = _detect_platform()
	host = _detect_host()


static func _detect_platform() -> Type:
	if OS.has_feature("windows"): return Type.WINDOWS
	if OS.has_feature("macos"): return Type.MACOS
	if OS.has_feature("linux"): return Type.LINUX
	if OS.has_feature("web_android"): return Type.WEB_ANDROID
	if OS.has_feature("web_ios"): return Type.WEB_IOS
	if OS.has_feature("android"): return Type.ANDROID
	if OS.has_feature("ios"): return Type.IOS
	return Type.OTHER


static func _detect_host() -> Host:
	if OS.has_feature("pc"): return Host.PC
	if OS.has_feature("mobile"): return Host.MOBILE
	if OS.has_feature("web"): return Host.WEB
	return Host.OTHER
