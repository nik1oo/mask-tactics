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

u_rect_rotate :: proc(rect_in: Rect) -> (rect_out: Rect) {
	center := rect_center(rect_in)
	rect_out = Rect{
		x = center.x - rect_in.height / 2,
		y = center.y - rect_in.width / 2,
		width = rect_in.height,
		height = rect_in.width }
	return rect_out }

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
		if state.grabbed_mask_class != "" do for point, i in state.grabbed_mask_points {
			if state.grabbed_mask_shape[i] == 1 do if u_point_inside_rect(rect, point) do hovered = true }
		g_draw_rect(rect, hovered ? RED : BLACK) } }

// The inventory contains items you are holding.
u_inventory :: proc() {
	hovered := u_hover_rect(state.rect_inventory)
	g_draw_rect(state.rect_inventory, hovered ? RED : BLACK)
	some_grabbed: bool = false
	for _, i in state.level.masks {
		mask := &state.level.masks[i]
		mask_class := state.mask_classes[mask.class_name]
		scale: f32
		switch {
		case mask.grabbed: scale = state.mask_scale_grid
		case mask.in_inventory:
			scale = MASK_SCALE_INVENTORY
		case: scale = MASK_SCALE_FREE }
		rect := m_mask_rect(mask.pos, mask_class, scale)
		hover_rect: Rect = rect
		hover_rect.x = rect.x - rect.width / 2
		hover_rect.y = rect.y - rect.height / 2
		if abs(mask.rotation) % 2 == 1 do hover_rect = u_rect_rotate(hover_rect)
		if mask.grabbed do mask.pos += state.mouse_delta
		if u_hover_rect(hover_rect) && (! some_grabbed) {
			if raylib.IsMouseButtonPressed(.LEFT) {
				mask.grabbed = true
				state.grabbed_mask_points = make([][2]f32, len(mask_class.shape))
				state.grabbed_mask_shape = mask_class.shape
				state.grabbed_mask_class = mask.class_name } }
		m_draw_mask(mask^, rect)
		// g_draw_rect_lines(hover_rect, RED)
		if mask.grabbed {
			some_grabbed = true
			for _, i in 0 ..< mask_class.size.x do for _, j in 0 ..< mask_class.size.y {
				point_index: int = m_mask_point_index(i, j, mask_class.size)
				state.grabbed_mask_points[point_index] = mask.pos + { 0.5 - 0.5 * cast(f32)mask_class.size.x + cast(f32)i, 0.5 - 0.5 * cast(f32)mask_class.size.y + cast(f32)j } * scale
				if mask_class.shape[point_index] == 1 do g_draw_point(state.grabbed_mask_points[len(state.grabbed_mask_points) - 1], raylib.RED) }
			if raylib.IsMouseButtonReleased(.LEFT) {
				if u_point_inside_rect(state.rect_inventory, mask.pos) {
					mask.in_inventory = true }
				else {
					mask.in_inventory = false
					// size = { 2, 2 },
					// shape = slice.clone([]u8{
					// 	1, 0,
					// 	1, 1 }) })
					// for _, i in 0 ..< mask_class.size.x do for _, j in 0 ..< mask_class.size.y {
					// 	g_draw_point(mask.pos + { 0.5 * cast(f32)i, 0.5 * cast(f32)j } * state.mask_scale_grid, BLUE)
				}
				mask.grabbed = false
				state.grabbed_mask_class = "" }
			// (TODO): Why does this cause a bug?
			// delete(state.grabbed_mask_points)
			if raylib.GetMouseWheelMove() < 0.0 do mask.rotation = (mask.rotation + 1) % 4
			if raylib.GetMouseWheelMove() > 0.0 do mask.rotation = (mask.rotation - 1) % 4 } } }

u_hover_rect :: proc(rect: Rect) -> bool {
	return raylib.CheckCollisionPointRec(state.mouse_pos, rect) }

u_point_inside_rect :: proc(rect: Rect, point: [2]f32) -> bool {
	return raylib.CheckCollisionPointRec(point, rect) }
