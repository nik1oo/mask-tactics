package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"

Stats :: struct {
	walking_speed: f32 }

s_init :: proc() {
	state.stats.walking_speed = DEFAULT_WALKING_SPEED }
