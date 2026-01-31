package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"
import "core:math/rand"

Level :: struct {
	props: [dynamic]Prop,
	enemies: [dynamic]Enemy,
	projectiles: [dynamic]Projectile }

// spawns behind

l_generate_new :: proc() {
	delete(state.level.props)
	state.level.props = make_dynamic_array_len_cap([dynamic]Prop, 0, PROPS_CAP)
	// (TODO): Spawn random trees within the "world_rect".
	s_init()
	points := l_random_points(state.world_rect, 800)
	for _, i in points {
		append(&state.level.enemies, e_new_enemy("Archer", points[i]))
		enemy := &state.level.enemies[i]
		enemy.health = rand.float32_range(0.0, state.enemy_classes[enemy.class_name].max_health) }
	delete(state.level.projectiles)
	state.level.projectiles = make_dynamic_array_len_cap([dynamic]Projectile, 0, PROJECTILES_CAP) }

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
	for _, i in state.level.projectiles do p_update_projectile(&state.level.projectiles[i]) }
