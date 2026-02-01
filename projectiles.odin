package mask_tactics
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"

Projectile :: struct {
	class: string,
	pos: [2]f32,
	virtual_height: f32,
	direction: [2]f32,
	shot_by_player: bool,
	timer: Timer }

Projectile_Class :: struct {
	sprite_name: string,
	fall_speed: f32,
	initial_angle: f32,
	size: [2]f32,
	speed: f32,
	damage: f32,
	sound_name: string,
	spinning: bool,
	lifetime: f32 }

p_init :: proc() {
	state.projectile_classes = make(map[string]Projectile_Class)
	p_new_projectile_class("Arrow", Projectile_Class{
		sprite_name = "arrow-test.png",
		size = { 100, 20},
		speed = 10.0,
		damage = 10.0,
		sound_name = "sfx-arrow.wav",
		spinning = false,
		lifetime = 16.0 })
	p_new_projectile_class("Sword", Projectile_Class{
		sprite_name = "sword-test.png",
		size = { 100, 20},
		speed = 2.0,
		damage = 20.0,
		sound_name = "sfx-arrow.wav",
		spinning = true,
		lifetime = 0.5 }) }

p_new_projectile_class :: proc(name: string, projectile_class: Projectile_Class) {
	state.projectile_classes[name] = projectile_class }

p_draw_projectile :: proc(projectile: Projectile) {
	projectile_class := state.projectile_classes[projectile.class]
	// rotation: = - linalg.vector_angle_between([2]f32{ 1.0, 0.0 }, projectile.direction)
	rotation := vec_angle(projectile.direction)
	if projectile_class.spinning do rotation += 44 * read_timer(&state.game_timer)
	rect: Rect = { projectile.pos.x, projectile.pos.y, projectile_class.size.x, projectile_class.size.y }
	g_draw_sprite(projectile_class.sprite_name, rect, offset_ratio = { 0.5, 0.5 }, rotation = rotation) }

p_spawn_projectile :: proc(class_name: string, pos: [2]f32, direction: [2]f32, shot_by_player: bool) {
	projectile: Projectile = {
		class = class_name,
		pos = pos,
		virtual_height = 0.0,
		direction = direction,
		shot_by_player = shot_by_player }
	start_timer(&projectile.timer)
	append(&state.level.projectiles, projectile)
	class := state.projectile_classes[class_name]
	if class.sound_name != "" do a_play_sound_once(class.sound_name) }

p_update_projectile :: proc(index: int) -> (deleted: bool) {
	projectile := &state.level.projectiles[index]
	projectile_class := state.projectile_classes[projectile.class]
	projectile.pos += projectile_class.speed * projectile.direction
	if projectile.shot_by_player {
		for _, i in state.level.enemies {
			if u_point_inside_rect(u_rect_around_point(state.level.enemies[i].pos, CHARACTER_SIZE_BASIC), projectile.pos) {
				e_damage_enemy(i, projectile_class.damage)
				ordered_remove(&state.level.projectiles, index)
				return true } } }
	if ! projectile.shot_by_player {
		if u_point_inside_rect(u_rect_around_point(state.player_pos, CHARACTER_SIZE_BASIC), projectile.pos) {
			e_damage_player(projectile_class.damage)
			ordered_remove(&state.level.projectiles, index)
			return true } }
	if read_timer(&projectile.timer) > projectile_class.lifetime {
		ordered_remove(&state.level.projectiles, index)
		return true }
	return false }
