package mask_tactics
import "core:math"
import "core:fmt"
import "core:slice"

Mask_Class :: struct {
	sprite_name: string,
	size: [2]int,
	shape: []u8,
	description: string,
	effect: proc(mask: ^Mask) }

Mask :: struct {
	class_name: string,
	pos: [2]f32,
	in_inventory: bool,
	in_grid: bool,
	grid_pos: [2]int,
	rotation: int,
	grabbed: bool,
	timer: Timer,
	effect_executed: bool }

Mask_Drop :: struct {
	class_name: string,
	pos: [2]f32 }

mask_1_effect :: proc(mask: ^Mask) {
	if read_timer(&mask.timer) > 0.1 {
		p_spawn_projectile("Arrow", state.player_pos + { 0, - CHARACTER_SIZE_BASIC.y / 2 }, state.aim_direction, shot_by_player = true)
		restart_timer(&mask.timer)
		} }

mask_2_effect :: proc(mask: ^Mask) {
	if ! mask.effect_executed do state.stats.walking_speed *= 2 }

mask_3_effect :: proc(mask: ^Mask) {
	if read_timer(&mask.timer) > 1.0 {
		state.player_health += 5
		restart_timer(&mask.timer) } }

m_init :: proc() {
	state.mask_classes = make(map[string]Mask_Class)
	m_new_mask_class("Aztec 1", Mask_Class{
		sprite_name = "mask_01.png",
		size = { 2, 2 },
		shape = slice.clone([]u8{
			1, 0,
			1, 1 }),
		description = "Shoots arrows at enemies.",
		effect = mask_1_effect })
	m_new_mask_class("Aztec 2", Mask_Class{
		sprite_name = "mask_02.png",
		size = { 2, 2 },
		shape = slice.clone([]u8{
			1, 1,
			0, 1 }),
		description = "Doubles your movement speed.",
		effect = mask_2_effect })
	m_new_mask_class("Aztec 3", Mask_Class{
		sprite_name = "mask_03.png",
		size = { 3, 1 },
		shape = slice.clone([]u8{
			1, 1, 1 }),
		description = "Heals you for 5 HP every second.",
		effect = mask_3_effect })
	m_new_mask("Aztec 1") }

m_new_mask_class :: proc(name: string, mask_class: Mask_Class) {
	state.mask_classes[name] = mask_class }

m_new_mask :: proc(class_name: string) {
	mask: Mask = Mask{
		class_name = class_name,
		in_inventory = false }
	// TODO
}

m_draw_mask :: proc(mask: Mask, rect: Rect) {
	mask_class := state.mask_classes[mask.class_name]
	g_draw_sprite(mask_class.sprite_name, rect, rotation = 0.5 * cast(f32)mask.rotation * math.PI, offset_ratio = { 0.5, 0.5 }) }

m_draw_mask_drop :: proc(mask_drop: Mask_Drop) {
	mask_class := state.mask_classes[mask_drop.class_name]
	g_draw_sprite(mask_class.sprite_name, u_rect_around_point(mask_drop.pos, MASK_DROP_SIZE)) }

m_mask_rect :: proc(pos: [2]f32, class: Mask_Class, scale: f32) -> (rect: Rect) {
	size: [2]f32 = scale * [2]f32{ auto_cast class.size.x, auto_cast class.size.y }
	tile_size: [2]f32 = { size.x / f32(class.size.x), size.y / f32(class.size.y) }
	offset: [2]f32 = { 0, 0 }
	return { pos.x - offset.x, pos.y - offset.y, size.x, size.y } }

m_mask_point_index :: proc(i: int, j: int, size: [2]int) -> int {
	return j * size.x + i }

m_mask_effects :: proc() {
	for _, i in state.level.masks {
		mask := &state.level.masks[i]
		mask_class := state.mask_classes[mask.class_name]
		if mask.in_grid {
			mask_class.effect(mask)
			mask.effect_executed = true } } }
