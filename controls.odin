package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"
import "core:math/linalg"

c_update :: proc() {
	state.playarea_center = rect_center(state.rect_playarea)
	state.mouse_pos = raylib.GetMousePosition()
	state.mouse_delta = raylib.GetMouseDelta()
	state.aim_direction = linalg.normalize(state.mouse_pos - state.playarea_center)
	speed := state.stats.walking_speed
	if raylib.IsKeyDown(.A) {
		state.player_pos.x -= DELTA * speed
		state.player_direction = .LEFT }
	if raylib.IsKeyDown(.D) {
		state.player_pos.x += DELTA * speed
		state.player_direction = .RIGHT }
	if raylib.IsKeyDown(.W) do state.player_pos.y -= DELTA * speed
	if raylib.IsKeyDown(.S) do state.player_pos.y += DELTA * speed
	if raylib.IsMouseButtonPressed(.LEFT) do p_spawn_projectile("Arrow", state.player_pos + { 0, - CHARACTER_SIZE_BASIC.y / 2 }, state.aim_direction, shot_by_player = true) }
