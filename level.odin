package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"
import "core:math"
import "core:math/rand"
import "core:math/linalg"

Level :: struct {
	props: [dynamic]Prop,
	enemies: [dynamic]Enemy,
	projectiles: [dynamic]Projectile,
	masks: [dynamic]Mask,
	wave_timer: Timer }

// spawns behind

l_generate_new :: proc() {
	delete(state.level.props)
	state.level.props = make_dynamic_array_len_cap([dynamic]Prop, 0, PROPS_CAP)
	// (TODO): Spawn random trees within the "world_rect".
	s_init()
	points := l_random_points(state.world_rect, 800)
	// for _, i in points do e_spawn_enemy("Knight", points[i])
	delete(state.level.projectiles)
	state.level.projectiles = make_dynamic_array_len_cap([dynamic]Projectile, 0, PROJECTILES_CAP)
	state.level.masks = make_dynamic_array_len_cap([dynamic]Mask, 0, INVENTORY_MASKS_CAP)
	append(&state.level.masks, Mask{ class_name = "Aztec 1", pos = { 200, 150 }, in_inventory = true })
	append(&state.level.masks, Mask{ class_name = "Aztec 2", pos = { 400, 150 }, in_inventory = true })
	append(&state.level.masks, Mask{ class_name = "Aztec 3", pos = { 600, 150 }, in_inventory = true })
	state.player_max_health = PLAYER_MAX_HEALTH_DEFAULT
	state.player_health = state.player_max_health
	l_spawn_wave()
	start_timer(&state.level.wave_timer) }

l_random_points :: proc(rect: Rect, count: int) -> (points: [][2]f32) {
	points = make([][2]f32, count)
	x_low: f32 = rect.x
	x_high: f32 = rect.x + rect.width
	y_low: f32 = rect.y
	y_high: f32 = rect.y + rect.height
	for _, i in points {
		points[i].x = rand.float32_range(x_low, x_high)
		points[i].y = rand.float32_range(y_low, y_high) }
	return points }

// l_random_points_normal :: proc(rect: Rect, count: int) -> (points: [][2]f32) {
// 	// rand.float32_normal(mean = , stddev = )
// }

l_update :: proc() {
	for _, i in state.level.enemies do e_update_enemy(&state.level.enemies[i])
	for i := 0; i < len(state.level.projectiles); i += 1 {
		if p_update_projectile(i) do i -= 1 }
	for i := 0; i < len(state.level.enemies); i += 1 {
		if state.level.enemies[i].health == 0 {
			ordered_remove(&state.level.enemies, i)
			i -= 1 } }
	if read_timer(&state.level.wave_timer) > WAVE_INTERVAL {
		l_spawn_wave()
		restart_timer(&state.level.wave_timer) } }

l_spawn_wave :: proc() {
	for i in 0 ..< WAVE_SIZE {
		angle: f32 = rand.float32_range(0, 2 * math.PI)
		point: [2]f32 = state.player_pos + WAVE_SPAWN_RADIUS * [2]f32{ linalg.cos(angle), linalg.sin(angle) }
		e_spawn_enemy("Knight", point) } }
