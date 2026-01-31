package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"
import "core:math"
import "core:math/linalg"

Color:: raylib.Color
Rect:: raylib.Rectangle
Texture:: raylib.Texture
Camera:: raylib.Camera2D
Sprite:: struct {
	texture: Texture }
BLANK: Color : raylib.BLANK
PURPLE: Color : { 0x54,  0x0D, 0x6E, 0xFF }
RED: Color : { 0xEE, 0x42, 0x66, 0xFF }
YELLOW: Color : { 0xFF, 0xD2, 0x3F, 0xFF }
BLUE: Color : { 0x3B, 0xCE, 0xAC, 0xFF }
GREEN: Color : { 0x0E, 0xAD, 0x69, 0xFF }
WHITE: Color : { 0xF1, 0xF1, 0xF1, 0xFF }
BLACK: Color : { 0x0F, 0x0F, 0x0F, 0xFF }
Render_Texture :: raylib.RenderTexture

g_create_window :: proc(resolution: [2]f32, target_fps: f32, name: string) {
	state.resolution = DEFAULT_RESOLUTION
	state.target_fps = target_fps
	raylib.SetConfigFlags({ .WINDOW_RESIZABLE, .VSYNC_HINT })
	raylib.InitWindow(auto_cast resolution.x, auto_cast resolution.y, strings.clone_to_cstring(name))
	raylib.InitAudioDevice()
	raylib.SetTargetFPS(auto_cast target_fps) }

g_draw_rect :: proc(rect: Rect, color: Color) -> Rect {
	raylib.DrawRectangleRec(rect, color)
	return rect }

g_draw_bar :: proc(rect: Rect, color: Color, ratio: f32) -> Rect {
	rect_left, _ := u_rect_split_h(rect, ratio, 0.0)
	g_draw_rect(rect, BLACK)
	g_draw_rect(rect_left, RED)
	return rect }

g_load_sprite :: proc(name: string) {
	sprite: Sprite
	filepath, error: = os.join_path({ "./assets", name }, context.temp_allocator)
	assert(error == nil)
	fmt.assertf(os.exists(filepath), "File not found: %s", filepath)
	sprite.texture = raylib.LoadTexture(strings.clone_to_cstring(filepath))
	state.sprites[name] = sprite }

g_draw_sprite :: proc(name: string, rect: Rect, tint: Color = raylib.WHITE, flip_x: bool = false, flip_y: bool = false, rotation: f32 = 0.0, center_offset: bool = false) {
	fmt.assertf(name in state.sprites, "Sprite %s not found.", name)
	sprite := state.sprites[name]
	g_draw_texture(sprite.texture, rect, tint, flip_x, flip_y, rotation, center_offset) }


g_draw_texture :: proc(texture: Texture, rect: Rect, tint: Color = raylib.WHITE, flip_x: bool = false, flip_y: bool = false, rotation: f32 = 0.0, center_offset: bool = false) {
	source_rect := raylib.Rectangle { 0, 0, f32(texture.width), flip_y ? (- f32(texture.height)) : f32(texture.height) }
	offset: [2]f32 = center_offset ? { rect.width / 2, rect.height / 2 } : { 0, 0 }
	raylib.DrawTexturePro(texture, source_rect, rect, offset, linalg.to_degrees(rotation), tint)
	raylib.DrawCircle(auto_cast (rect.x), auto_cast (rect.y), 1.0, raylib.RED) }

g_load_render_texture :: proc(size: [2]f32) -> Render_Texture {
	return raylib.LoadRenderTexture(auto_cast size.x, auto_cast size.y) }

g_clear_render_texture :: proc(render_texture: Render_Texture) {
	raylib.BeginTextureMode(render_texture)
	raylib.ClearBackground(BLACK)
	raylib.EndTextureMode() }

g_begin_frame :: proc() {
	raylib.BeginDrawing()
	raylib.ClearBackground(BLACK) }

g_end_frame :: proc() {
	raylib.EndDrawing() }

g_begin_camera :: proc() {
	raylib.BeginMode2D(state.camera) }

g_end_camera :: proc() {
	raylib.EndMode2D() }
