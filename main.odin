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
TARGET_FPS:: 120
PURPLE: Color : { 0x54,  0x0D, 0x6E, 0xFF }
RED: Color : { 0xEE, 0x42, 0x66, 0xFF }
YELLOW: Color : { 0xFF, 0xD2, 0x3F, 0xFF }
BLUE: Color : { 0x3B, 0xCE, 0xAC, 0xFF }
GREEN: Color : { 0x0E, 0xAD, 0x69, 0xFF }
WHITE: Color : { 0xF1, 0xF1, 0xF1, 0xFF }
BLACK: Color : { 0x0F, 0x0F, 0x0F, 0xFF }

State :: struct {
	target_fps: f32,
	name: string,
	exit: bool,
	resolution: [2]f32,
	sounds: map[string]Sound }
state: ^State

init :: proc() {
	state = new(State)
	state.name = NAME
	rand.reset(transmute(u64)time.now()._nsec)
	g_create_window(DEFAULT_RESOLUTION, TARGET_FPS, state.name)
	state.sounds = make(map[string]Sound)
	a_load_sound("music.mp3")
	a_play_sound_once("music.mp3")
	// raylib.PlaySound(music_sound)
}

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
	raylib.BeginDrawing()
	raylib.ClearBackground(BLACK)

	// ...

	raylib.EndDrawing()
	free_all(context.temp_allocator) }
