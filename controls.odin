package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"

c_update :: proc() {
	speed := state.stats.walking_speed
	if raylib.IsKeyDown(.A) do state.player_pos.x -= DELTA * speed
	if raylib.IsKeyDown(.D) do state.player_pos.x += DELTA * speed
	if raylib.IsKeyDown(.W) do state.player_pos.y -= DELTA * speed
	if raylib.IsKeyDown(.S) do state.player_pos.y += DELTA * speed }
