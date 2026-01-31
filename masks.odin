package mask_tactics
import "core:fmt"

Mask_Class :: struct {
	sprite_name: string,
	size: [2]int,
	origin: [2]int }

Mask :: struct {
	class_name: string,
	pos: [2]f32,
	in_inventory: bool }

m_init :: proc() {
	state.mask_classes = make(map[string]Mask_Class)
	m_new_mask_class("Aztec 1", Mask_Class{
		sprite_name = "mask-aztec-1-test.png",
		size = { 2, 2 },
		origin = { 0, 0 } })
	m_new_mask_class("Aztec 2", Mask_Class{
		sprite_name = "mask-aztec-2-test.png",
		size = { 2, 2 },
		origin = { 1, 1 } })
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

m_draw_mask :: proc(mask: Mask) {
	mask_class := state.mask_classes[mask.class_name]
	rect := m_mask_rect(mask.pos, mask_class)
	g_draw_sprite(mask_class.sprite_name, rect) }

m_mask_rect :: proc(origin: [2]f32, class: Mask_Class) -> Rect {
	size: [2]f32 = MASK_SCALE_INVENTORY * [2]f32{ auto_cast class.size.x, auto_cast class.size.y }
	return { origin.x - size.x / 2, origin.y - size.y / 2, size.x, size.y } }
