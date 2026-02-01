package mask_tactics
import "core:fmt"
import "vendor:raylib"
import "core:strings"
import os "core:os/os2"
import "core:math/rand"

Sound :: struct {
	sound: raylib.Sound }

a_load_sound :: proc(name: string) {
	sound: Sound
	filepath, error: = os.join_path({ "./assets", name }, context.temp_allocator)
	assert(error == nil)
	fmt.assertf(os.exists(filepath), "File not found: %s", filepath)
	sound.sound = raylib.LoadSound(strings.clone_to_cstring(filepath))
	state.sounds[name] = sound }

a_play_sound_once :: proc(name: string) {
	fmt.assertf(name in state.sounds, "Sound not found: %s", name)
	raylib.PlaySound(state.sounds[name].sound) }

a_update_player_voice :: proc() {
	if state.player_voice_interval == 0.0 {
		start_timer(&state.player_voice_timer)
		state.player_voice_interval = rand.float32_range(PLAYER_VOICE_INTERVAL_RANGE[0], PLAYER_VOICE_INTERVAL_RANGE[1]) }
	if read_timer(&state.player_voice_timer) > state.player_voice_interval {
		a_play_sound_once(fmt.tprintf("sfx-player-%d.wav", 1 + rand.int31_max(3)))
		restart_timer(&state.player_voice_timer)
		state.player_voice_interval = rand.float32_range(PLAYER_VOICE_INTERVAL_RANGE[0], PLAYER_VOICE_INTERVAL_RANGE[1]) } }
