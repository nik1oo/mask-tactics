package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"

Sound :: struct {
	sound: raylib.Sound }

a_load_sound :: proc(name: string) {
	sound: Sound
	filepath, error: = os.join_path({ "./assets", name }, context.temp_allocator)
	assert(error == nil)
	fmt.println("Loading", filepath)
	fmt.assertf(os.exists(filepath), "File not found: %s", filepath)
	sound.sound = raylib.LoadSound(strings.clone_to_cstring(filepath))
	state.sounds[name] = sound }

a_play_sound_once :: proc(name: string) {
	fmt.assertf(name in state.sounds, "Sound not found: %s", name)
	raylib.PlaySound(state.sounds[name].sound) }
