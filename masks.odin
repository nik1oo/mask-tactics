package mask_tactics
import "core:math"
import "core:fmt"

Mask_Class :: struct {
	sprite_name: string,
	size: [2]int,
	origin: [2]int }

Mask :: struct {
	class_name: string,
	pos: [2]f32,
	in_inventory: bool,
	rotation: int }

m_init :: proc() {
	state.mask_classes = make(map[string]Mask_Class)
	m_new_mask_class("Aztec 1", Mask_Class{
		sprite_name = "mask-aztec-1-test.png",
		size = { 2, 2 },
		origin = { 0, 1 } })
	m_new_mask_class("Aztec 2", Mask_Class{
		sprite_name = "mask-aztec-2-test.png",
		size = { 2, 2 },
		origin = { 1, 0 } })
	m_new_mask_class("Aztec 3", Mask_Class{
		sprite_name = "mask-aztec-3-test.png",
		size = { 3, 1 },
		origin = { 1, 0 } })
	m_new_mask("Aztec 1") }

m_new_mask_class :: proc(name: string, mask_class: Mask_Class) {
	state.mask_classes[name] = mask_class }

m_new_mask :: proc(class_name: string) {
	mask: Mask = Mask{
		class_name = class_name,
		in_inventory = true }
	// TODO
}

m_draw_mask :: proc(mask: Mask, rect: Rect) {
	mask_class := state.mask_classes[mask.class_name]
	g_draw_sprite(mask_class.sprite_name, rect, rotation = 0.5 * cast(f32)mask.rotation * math.PI, offset_ratio = { (1.0 / cast(f32)mask_class.size.x) * (0.5 + cast(f32)mask_class.origin.x), (1.0 / cast(f32)mask_class.size.y) * (0.5 + cast(f32)mask_class.origin.y) }) }

m_mask_rect :: proc(pos: [2]f32, class: Mask_Class) -> (rect: Rect) {
	size: [2]f32 = MASK_SCALE_INVENTORY * [2]f32{ auto_cast class.size.x, auto_cast class.size.y }
	tile_size: [2]f32 = { size.x / f32(class.size.x), size.y / f32(class.size.y) }
	offset: [2]f32 = { tile_size.x * (0.5 + cast(f32)class.origin.x), tile_size.y * (0.5 + cast(f32)class.origin.y) }
	// offset: [2]f32 = { size.x / f32(class.size.x) * class.origin.x, size.y / f32(class.size.y) * class.origin.y }
	// class.origin
	return { pos.x - offset.x, pos.y - offset.y, size.x, size.y } }
