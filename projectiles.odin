package mask_tactics
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"

Projectile :: struct {
	class: string,
	pos: [2]f32,
	virtual_height: f32,
	direction: [2]f32 }

Projectile_Class :: struct {
	sprite_name: string,
	fall_speed: f32,
	initial_angle: f32,
	size: [2]f32,
	speed: f32 }

p_init :: proc() {
	state.projectile_classes = make(map[string]Projectile_Class)
	p_new_projectile_class("Arrow", Projectile_Class{
		sprite_name = "arrow-test.png",
		size = { 100, 20},
		speed = 10.0 }) }

p_new_projectile_class :: proc(name: string, projectile_class: Projectile_Class) {
	state.projectile_classes[name] = projectile_class }

p_draw_projectile :: proc(projectile: Projectile) {
	projectile_class := state.projectile_classes[projectile.class]
	rotation: = - linalg.vector_angle_between([2]f32{ 1.0, 0.0 }, projectile.direction)
	// rotation = vec_angle(projectile.direction)
	rect: Rect = { projectile.pos.x, projectile.pos.y, projectile_class.size.x, projectile_class.size.y }
	g_draw_sprite(projectile_class.sprite_name, rect, offset_ratio = { 0.5, 0.5 }, rotation = rotation) }

p_spawn_projectile :: proc(class: string, pos: [2]f32, direction: [2]f32) {
	projectile: Projectile = {
		class = class,
		pos = pos,
		virtual_height = 0.0,
		direction = direction }
	append(&state.level.projectiles, projectile) }

p_update_projectile :: proc(projectile: ^Projectile) {
	projectile_class := state.projectile_classes[projectile.class]
	projectile.pos += projectile_class.speed * projectile.direction }
