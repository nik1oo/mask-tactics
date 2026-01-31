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
	if raylib.IsKeyDown(.A) do state.player_pos.x -= DELTA * speed
	if raylib.IsKeyDown(.D) do state.player_pos.x += DELTA * speed
	if raylib.IsKeyDown(.W) do state.player_pos.y -= DELTA * speed
	if raylib.IsKeyDown(.S) do state.player_pos.y += DELTA * speed
	if raylib.IsMouseButtonPressed(.LEFT) do p_spawn_projectile("Arrow", state.player_pos, state.aim_direction) }
