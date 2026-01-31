package mask_tactics
import "core:fmt"
import "vendor:raylib"

// prototype.png

u_rect_margins :: proc(rect_in: Rect, margins: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.x += margins
	rect_out.y += margins
	rect_out.width -= margins * 2
	rect_out.height -= margins * 2
	return rect_out }

u_rect_split_h :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_left: Rect, rect_right: Rect) {
	rect_left = rect_in
	rect_right = rect_in
	rect_left.width = rect_in.width * ratio
	rect_right.width = rect_in.width * (1.0 - ratio)
	rect_right.x += rect_left.width
	rect_left.width -= margin / 2
	rect_right.width -= margin / 2
	rect_right.x += margin / 2
	return rect_left, rect_right }

u_rect_split_v :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_top: Rect, rect_bottom: Rect) {
	rect_top = rect_in
	rect_bottom = rect_in
	rect_top.height = rect_in.height * ratio
	rect_bottom.height = rect_in.height * (1.0 - ratio)
	rect_bottom.y += rect_top.height
	rect_top.height -= margin / 2
	rect_bottom.height -= margin / 2
	rect_bottom.y += margin / 2
	return rect_top, rect_bottom }

u_rect_grid :: proc(rect_in: Rect, size: [2]int) -> (rects_out: [][]Rect) {
	rects_out = make([][]Rect, size.x)
	rect_width: f32 = rect_in.width / cast(f32)size.x
	rect_height: f32 = rect_in.height / cast(f32)size.y
	for _, i in 0 ..< size.x do rects_out[i] = make([]Rect, size.y)
	for _, i in 0 ..< size.x do for _, j in 0 ..< size.y {
		rect := &rects_out[i][j]
		rect^ = rect_in
		rect.x += rect_width * cast(f32)i
		rect.y += rect_height * cast(f32)j
		rect.width = rect_width
		rect.height = rect_height }
	return rects_out }

u_screen_rect :: proc() -> Rect {
	return Rect{ 0.0, 0.0, state.resolution.x, state.resolution.y } }

u_grid :: proc(mask_rect: Rect) {

	// grid_size
}

u_begin_playarea :: proc() {
	raylib.BeginTextureMode(state.playarea_texture)
	raylib.BeginBlendMode(.ALPHA) }

u_end_playarea :: proc() {
	raylib.EndBlendMode()
	raylib.EndTextureMode() }

u_mask_grid :: proc() {
	for i in 0 ..< len(state.rect_mask_grid) do for j in 0 ..< len(state.rect_mask_grid[0]) {
		rect := state.rect_mask_grid[i][j]
		hovered := u_hover_rect(rect)
		g_draw_rect(rect, hovered ? RED : BLACK) } }

// The inventory contains items you are holding.
u_inventory :: proc() {
	hovered := u_hover_rect(state.rect_inventory)
	g_draw_rect(state.rect_inventory, hovered ? RED : BLACK)
	fmt.println(len(state.level.masks))
	for _, i in state.level.masks {
		mask := &state.level.masks[i]
		if raylib.GetMouseWheelMove() < 0.0 do mask.rotation = (mask.rotation + 1) % 4
		if raylib.GetMouseWheelMove() > 0.0 do mask.rotation = (mask.rotation - 1) % 4
		mask_class := state.mask_classes[mask.class_name]
		rect := m_mask_rect(mask.pos, mask_class)
		if u_hover_rect(rect) do rect = u_rect_margins(rect, -8.0)
		m_draw_mask(mask^, rect) }
}

u_hover_rect :: proc(rect: Rect) -> bool {
	return raylib.CheckCollisionPointRec(state.mouse_pos, rect) }
