package mask_tactics
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"

BASE_EVADE_INTERVAL:: 100.0

Prop :: struct {
	class_name: string,
	pos: [2]f32 }

Prop_Class :: struct {
	sprite_name: string }

Enemy :: struct {
	class_name: string,
	pos: [2]f32,
	health: f32,
	move_target: [2]f32,
	state: Enemy_State,
	state_timer: Timer,
	auxiliary_timer: Timer,
	evade_direction: i8 }

Enemy_State :: enum {
	STANDING,
	CHASING,
	EVADING,
	DANCING }

Enemy_Class :: struct {
	max_health: f32,            // Maximum health.
	movement_speed: f32,        // Base movement speed.
	spawns_behind_player: bool, // Whether it spawns behind the player.
	agility: f32,               // How quickly it changes direction while evading.
	state_duration: [Enemy_State]f32 }

e_rand_state :: proc() -> Enemy_State {
	return auto_cast rand.int31_max(len(Enemy_State)) }

e_new_enemy :: proc(class_name: string, pos: [2]f32) -> (enemy: Enemy) {
	fmt.assertf(class_name in state.enemy_classes, "Enemy class %s does not exist.", class_name)
	enemy.class_name = class_name
	enemy.pos = pos
	enemy.health = state.enemy_classes[class_name].max_health
	enemy.state = e_rand_state()
	enemy.evade_direction = (rand.int31_max(2) == 0) ? (+1) : (-1)
	start_timer(&enemy.auxiliary_timer)
	start_timer(&enemy.state_timer)
	return enemy }

e_new_enemy_class :: proc(name: string, class: Enemy_Class) {
	state.enemy_classes[name] = class }

e_new_prop_class :: proc(name: string, sprite_name: string) {
	state.prop_classes[name] = { sprite_name = sprite_name } }

e_init :: proc() {
	state.enemy_classes = make(map[string]Enemy_Class)
	e_new_enemy_class("Archer", Enemy_Class{
		max_health = 200,
		movement_speed = 100,
		spawns_behind_player = false,
		agility = 100.0,
		state_duration = { .STANDING = 1.0, .CHASING = 1.0, .EVADING = 1.0, .DANCING = 0.0 } })
	e_new_enemy_class("Horseman", Enemy_Class{ max_health = 200, movement_speed = 100, spawns_behind_player = false, agility = 100.0 })
	state.prop_classes = make(map[string]Prop_Class)
	e_new_prop_class("tree", "prop-tree-test.png") }

e_draw_player :: proc() {
	// pos: [2]f32 = state.player_pos
	// size: [2]f32 = { 64, 64 }
	// g_draw_sprite("knight-test.png", Rect{ pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y })
	e_draw_character("knight-test.png", state.player_pos) }

e_draw_character :: proc(sprite_name: string, pos: [2]f32, health_ratio: f32 = 1.0) {
	size: [2]f32 = CHARACTER_SIZE_BASIC
	g_draw_sprite(sprite_name, Rect{ pos.x - size.x / 2, pos.y - size.y / 2, size.x, size.y })
	healthbar_rect: = Rect{ pos.x - size.x / 2, pos.y - size.y / 2 - HEALTHBAR_MARGIN, HEALTHBAR_SIZE.x, HEALTHBAR_SIZE.y }
	g_draw_bar(healthbar_rect, RED, health_ratio) }

e_draw_enemy :: proc(enemy: Enemy) {
	health_ratio: f32 = enemy.health / state.enemy_classes[enemy.class_name].max_health
	switch enemy.class_name {
	case "Archer": e_draw_character("archer-test.png", enemy.pos, health_ratio)
	case "Horseman": e_draw_character("horseman-test.png", enemy.pos, health_ratio) } }

e_get_enemy_class :: proc(enemy: Enemy) -> Enemy_Class {
	return state.enemy_classes[enemy.class_name] }

e_update_enemy :: proc(enemy: ^Enemy) {
	enemy_class := e_get_enemy_class(enemy^)
	switch enemy.state {
	case .STANDING:
		enemy.move_target = enemy.pos
	case .CHASING:
		enemy.move_target = state.player_pos
	case .EVADING:
		player_vector: [2]f32 = linalg.normalize(state.player_pos - enemy.pos)
		evade_vector: [2]f32 = linalg.matrix2_rotate_f32(math.PI / 2.0) * player_vector
		if enemy.evade_direction < 0 do evade_vector = - evade_vector
		enemy.move_target = enemy.pos + 100 * evade_vector
		evade_interval: f32 = BASE_EVADE_INTERVAL / enemy_class.agility
		if read_timer(&enemy.auxiliary_timer) > evade_interval {
			enemy.evade_direction = - enemy.evade_direction
			restart_timer(&enemy.auxiliary_timer) }
	case .DANCING: }
	if read_timer(&enemy.state_timer) > enemy_class.state_duration[enemy.state] {
		enemy.state = e_rand_state()
		restart_timer(&enemy.state_timer) }
	direction: [2]f32 = {}
	if enemy.move_target != enemy.pos do direction = linalg.normalize(enemy.move_target - enemy.pos)
	enemy.pos += DELTA * direction * enemy_class.movement_speed }

e_damage_enemy :: proc(index: int, damage: f32) {
	enemy := &state.level.enemies[index]
	enemy.health = max(0, enemy.health - damage)
	// fmt.println("damaging enemy", enemy.health + damage, enemy.health)
}
