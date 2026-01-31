package mask_tactics

import "vendor:raylib"
import "core:log"
import "core:fmt"
import "core:c"
import "core:math"
import "core:math/linalg"
import "core:hash"
import "core:math/bits"
import "core:math/rand"
import "core:strings"
import "core:slice"
import "core:time"

NAME: string : "Mask Tactics"
DEFAULT_RESOLUTION: [2]f32 : { 1792, 1008 }
TARGET_FPS:: 120
STARTING_GRID_SIZE: [2]int : { 4, 4 }

State :: struct {
	target_fps: f32,
	name: string,
	exit: bool,
	resolution: [2]f32,
	sounds: map[string]Sound,
	sprites: map[string]Sprite,
	grid_size: [2]int,
	playarea_size: [2]f32,
	playarea_texture: Render_Texture,
	screen_rect: Rect,
	rect_inventory: Rect,
	rect_mask: Rect,
	rect_timer: Rect,
	rect_playarea: Rect,
	rect_mask_grid: [][]Rect }
state: ^State

init :: proc() {
	state = new(State)
	state.name = NAME
	rand.reset(transmute(u64)time.now()._nsec)
	g_create_window(DEFAULT_RESOLUTION, TARGET_FPS, state.name)
	state.sounds = make(map[string]Sound)
	a_load_sound("music.mp3")
	a_play_sound_once("music.mp3")
	g_load_sprite("prototype.png")
	// raylib.PlaySound(music_sound)
	state.grid_size = STARTING_GRID_SIZE
	state.screen_rect = u_screen_rect()
	rect := u_rect_margins(state.screen_rect, 48)
	rect_left, rect_right := u_rect_split_h(rect, 0.4, 48)
	state.rect_inventory, state.rect_mask = u_rect_split_v(rect_left, 0.285, 48)
	state.rect_timer, state.rect_playarea = u_rect_split_v(rect_right, 0.05, 24)
	state.rect_mask = u_rect_margins(state.rect_mask, 8)
	state.rect_mask_grid = u_rect_grid(state.rect_mask, state.grid_size)
	for i in 0 ..< len(state.rect_mask_grid) do for j in 0 ..< len(state.rect_mask_grid[0]) {
		rect := state.rect_mask_grid[i][j]
		state.rect_mask_grid[i][j] = u_rect_margins(rect, 8) }
	state.playarea_size = [2]f32{ state.rect_playarea.width, state.rect_playarea.height }
	state.playarea_texture = g_load_render_texture(state.playarea_size)
	fmt.println(state.playarea_size) }

shutdown :: proc() {
	raylib.CloseAudioDevice()
	raylib.CloseWindow() }

running :: proc() -> bool {
	return ! (raylib.WindowShouldClose() || state.exit) }

main :: proc() {
	init()
	for running() do update()
	shutdown() }

update :: proc() {
	g_begin_frame()
	g_clear_render_texture(state.playarea_texture)
// prototype.png
	// ...
	g_draw_sprite("prototype.png", state.screen_rect)
	g_draw_rect(state.rect_inventory, BLACK)
	g_draw_rect(state.rect_mask, BLUE)
	g_draw_rect(state.rect_timer, BLACK)
	// g_draw_rect(state.rect_playarea, BLACK)
	for i in 0 ..< len(state.rect_mask_grid) do for j in 0 ..< len(state.rect_mask_grid[0]) do g_draw_rect(state.rect_mask_grid[i][j], BLACK)

	u_begin_playarea()
	g_draw_rect(Rect{ 100, 100, 100, 100 }, RED)
	u_end_playarea()

	g_draw_texture(state.playarea_texture.texture, state.rect_playarea)
	g_end_frame()
	free_all(context.temp_allocator) }
