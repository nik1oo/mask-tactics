package mask_tactics
import "vendor:raylib"
import "core:strings"

Color :: raylib.Color

g_create_window :: proc(resolution: [2]f32, target_fps: f32, name: string) {
	state.resolution = DEFAULT_RESOLUTION
	state.target_fps = target_fps
	raylib.SetConfigFlags({ .WINDOW_RESIZABLE, .VSYNC_HINT })
	raylib.InitWindow(auto_cast resolution.x, auto_cast resolution.y, strings.clone_to_cstring(name))
	raylib.InitAudioDevice()
	raylib.SetTargetFPS(auto_cast target_fps) }
