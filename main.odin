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
DEFAULT_WALKING_SPEED:: 200.0
FPS:: 120
DELTA: f32 : 1.0 / cast(f32)FPS
STARTING_GRID_SIZE: [2]int : { 4, 4 }
PROPS_CAP: int : 100
PROJECTILES_CAP: int : 10000
WORLD_SIZE: [2]f32 : { 5000, 5000 }
HEALTHBAR_MARGIN: f32 : 16.0
HEALTHBAR_SIZE: [2]f32 : { 64, 2 }
MASK_SCALE_INVENTORY :: 48.0
MASK_SCALE_FREE :: 128.0
INVENTORY_MASKS_CAP :: 16
CHARACTER_SIZE_BASIC: [2]f32 : { 64, 64 }
PLAYER_VOICE_INTERVAL_RANGE: [2]f32 : { 4.0, 10.0 }
PLAYER_MAX_HEALTH_DEFAULT: f32 : 500
WAVE_SPAWN_RADIUS: f32 : 500.0
WAVE_SIZE: int: 8

State :: struct {
	target_fps: f32,
	name: string,
	exit: bool,
	resolution: [2]f32,
	sounds: map[string]Sound,
	sprites: map[string]Sprite,
	grid_size: [2]int,
	playarea_size: [2]f32,
	mask_scale_grid: f32,
	playarea_texture: Render_Texture,
	screen_rect: Rect,
	rect_inventory: Rect,
	rect_mask: Rect,
	rect_timer: Rect,
	rect_playarea: Rect,
	rect_mask_grid: [][]Rect,
	camera: Camera,
	prop_classes: map[string]Prop_Class,
	world_rect: Rect,
	player_pos: [2]f32,
	stats: Stats,
	level: Level,
	enemy_classes: map[string]Enemy_Class,
	projectile_classes: map[string]Projectile_Class,
	game_timer: Timer,
	game_time: f32,
	aim_direction: [2]f32,
	playarea_center: [2]f32,
	mouse_pos: [2]f32,
	mouse_delta: [2]f32,
	mask_classes: map[string]Mask_Class,
	grabbed_mask_class: string,
	grabbed_mask_points: [][2]f32,
	grabbed_mask_shape: []u8,
	player_voice_timer: Timer,
	player_voice_interval: f32,
	player_direction: Direction,
	player_health: f32,
	player_max_health: f32 }
state: ^State

init :: proc() {
	state = new(State)
	state.name = NAME
	rand.reset(transmute(u64)time.now()._nsec)
	g_create_window(DEFAULT_RESOLUTION, FPS, state.name)
	state.sounds = make(map[string]Sound)
	a_load_sound("sfx-arrow.wav")
	a_load_sound("sfx-player-1.wav")
	a_load_sound("sfx-player-2.wav")
	a_load_sound("sfx-player-3.wav")
	g_load_sprite("UI_screen.png")
	g_load_sprite("prototype.png")
	g_load_sprite("terrain.png")
	// g_load_sprite("terrain-displacement.png")
	g_load_sprite("prop-tree-test.png")
	g_load_sprite("knight-test.png")
	g_load_sprite("archer-test.png")
	g_load_sprite("horseman-test.png")
	g_load_sprite("arrow-test.png")
	g_load_sprite("mask_01.png")
	g_load_sprite("mask_02.png")
	g_load_sprite("mask_03.png")
	g_load_sprite("mage-left.png")
	g_load_sprite("mage-right.png")
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
	state.camera = { zoom = 1.0 }
	state.world_rect = Rect{ 0, 0, WORLD_SIZE.x, WORLD_SIZE.y }
	state.player_pos = { WORLD_SIZE.x / 2, WORLD_SIZE.y / 2 }
	p_init()
	e_init()
	m_init()
	l_generate_new()
	start_timer(&state.game_timer) }

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
	state.game_time = read_timer(&state.game_timer)
	g_begin_frame()
	g_clear_render_texture(state.playarea_texture)
	c_update()
	l_update()
	a_update_player_voice()
	state.mask_scale_grid = state.rect_mask.width / cast(f32)state.grid_size.x
// prototype.png
	// ...
	u_begin_playarea()
		state.camera.target = state.player_pos
		state.camera.offset = [2]f32{ state.playarea_size.x, state.playarea_size.y } / 2
		g_begin_camera()
		// g_draw_rect(state.world_rect, Color{ 50, 50, 50, 255 })
		g_draw_sprite("terrain.png", state.world_rect)
		for enemy in state.level.enemies do e_draw_enemy(enemy)
		e_draw_player()
		for projectile in state.level.projectiles do p_draw_projectile(projectile)
		// p_draw_projectile(Projectile{
		// 	class = "Arrow",
		// 	pos = { state.player_pos.x + 200.0, state.player_pos.y },
		// 	direction = linalg.normalize([2]f32{ 2, -1 })
		// 	// direction = { math.cos(2 * state.game_time), math.sin(2 * state.game_time) }
		// 	})
		g_end_camera()
	u_end_playarea()
	g_draw_texture(state.playarea_texture.texture, state.rect_playarea, flip_y = true)
	g_draw_sprite("UI_screen.png", state.screen_rect)
	g_draw_rect_lines(state.rect_mask, BLACK)
	g_draw_rect(state.rect_timer, BLACK)
	// g_draw_rect(state.rect_playarea, BLACK)
	u_mask_grid()
	u_inventory()
	pos := state.playarea_center + 100 * state.aim_direction
	// raylib.DrawCircle(auto_cast (pos.x), auto_cast (pos.y), 4.0, raylib.GREEN)
	g_end_frame()
	free_all(context.temp_allocator) }
