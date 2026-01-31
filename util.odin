package mask_tactics
import "core:time"
import "core:math"
import "core:math/linalg"

Timer :: time.Stopwatch

resume_timer :: start_timer

start_timer :: proc (timer : ^Timer) {
	time.stopwatch_start(timer) }

pause_timer :: proc (timer : ^Timer) {
	time.stopwatch_stop(timer) }

stop_timer :: proc (timer : ^Timer) {
	time.stopwatch_stop(timer) }

restart_timer :: proc (timer : ^Timer) {
	time.stopwatch_reset(timer)
	time.stopwatch_start(timer) }

read_timer :: proc (timer : ^Timer) -> f32 {
	return f32(time.duration_seconds(time.stopwatch_duration(timer^))) }

angle_vec :: proc (angle : f32) -> [2]f32 {
	return linalg.normalize([2]f32{math.cos(angle), math.sin(angle)}) }

vec_angle :: proc (vec : [2]f32) -> f32 {
	vec := vec
	vec = linalg.normalize(vec)
	angle : f32
	if vec.y > 0 {
		angle = linalg.acos(vec.x) } else {
		angle = -linalg.acos(vec.x) }
	return angle }

rect_center :: proc(rect: Rect) -> [2]f32 {
	return { rect.x + rect.width / 2, rect.y + rect.height / 2 } }
