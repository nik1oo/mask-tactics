package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"

Level :: struct {
	props: [dynamic]Prop,
	enemies: [dynamic]Enemy }

// spawns behind

l_generate_new :: proc() {
	delete(state.level.props)
	state.level.props = make_dynamic_array_len_cap([dynamic]Prop, 0, PROPS_CAP)
	// (TODO): Spawn random trees within the "world_rect".
	s_init() }
