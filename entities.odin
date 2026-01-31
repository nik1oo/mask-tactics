package mask_tactics

Prop :: struct {
	class_name: string,
	pos: [2]f32 }

Prop_Class :: struct {
	sprite_name: string }

Enemy :: struct {
	type: Enemy_Type,
	pos: [2]f32 }

Enemy_Type :: enum {
	ARCHER }

// Enemy_Class :: struct {
	// spawns_behind_player: bool
// }

e_new_prop_class :: proc(name: string, sprite_name: string) {
	state.prop_classes[name] = { sprite_name = sprite_name } }

e_init :: proc() {
	state.prop_classes = make(map[string]Prop_Class)
	e_new_prop_class("tree", "prop-tree-test.png") }

e_draw_player :: proc() {
	// pos: [2]f32 = state.player_pos
	// size: [2]f32 = { 64, 64 }
	// g_draw_sprite("knight-test.png", Rect{ pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y })
	e_draw_character("knight-test.png", state.player_pos) }

e_draw_character :: proc(sprite_name: string, pos: [2]f32) {
	size: [2]f32 = { 64, 64 }
	g_draw_sprite(sprite_name, Rect{ pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y }) }

e_draw_enemy :: proc(type: Enemy_Type, pos: [2]f32) {
	switch type {
	case .ARCHER: e_draw_character("archer-test.png", pos) } }
