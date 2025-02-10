package handles
import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"


EntityHandle :: distinct Handle
Entity :: struct {
	handle: EntityHandle,
	position: [2]f32,
	color: rl.Color,
	connected_to: EntityHandle
}

windowsize : [2]f32


regen_entities :: proc(entities: ^Handle_Array($T, $HT)) {
	ha_clear(entities)
	for i := 0; i < 50; i += 1 {
		x := rand.float32() * (windowsize.x - 30)
		y := rand.float32() * (windowsize.y - 30)
		ha_add(entities, Entity{
			position = {x, y},
			color = rl.WHITE
		})
	}
}



main :: proc() {
	windowsize = {1024, 768}
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(i32(windowsize.x), i32(windowsize.y), "handle this")

	entities: Handle_Array(Entity, EntityHandle)

	regen_entities(&entities)

	selected_handle: EntityHandle
	connecting: bool

	for !rl.WindowShouldClose() {

		mouse_position := rl.GetMousePosition()

		if rl.IsWindowResized() {
			windowsize = {f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
		}

		on_entity: bool

		rl.BeginDrawing()
			rl.ClearBackground(0)

			ee := ha_make_iter(entities)
			size: [2]f32 = {30, 15}
			for e in ha_iter_ptr(&ee) {
				p := e.position
				color := e.color
				rl.DrawRectangleV(p - 1, size + 2, rl.BLACK)

				if !on_entity && mouse_position.x >= p.x && mouse_position.x <= p.x + size.x + 2 &&
				mouse_position.y >= p.y && mouse_position.y <= p.y + size.y + 2 {
					on_entity = true
					rl.DrawRectangleV(p - 2, size + 4, rl.BLUE)
					if rl.IsMouseButtonPressed(.LEFT) {

						if selected_handle == {} {
							selected_handle = e.handle
							e.connected_to = {}
						} else if selected_handle != e.handle {
							selected_entity := ha_get_ptr(entities, selected_handle)
							selected_entity.connected_to = e.handle
							selected_handle = {}
							connecting = false
						}
					} else if !connecting && rl.IsMouseButtonPressed(.RIGHT) {
						ha_remove(&entities, e.handle)
						break // break out of loop here to avoid collisions. this type of thing could be avoided with a state machine
					}
				}
				rl.DrawRectangleV(p, size, color)
				rl.DrawText(fmt.ctprintf("%v, %v", e.handle.idx, e.handle.gen), i32(p.x) + 2, i32(p.y) + 2, 10, rl.BLACK)


				if connected_to, ok := ha_get(entities, e.connected_to) ; ok {
					rl.DrawLineV(p + size, connected_to.position, rl.GREEN)
					rl.DrawCircleV(connected_to.position, 4, rl.RED)
				} else if selected_handle == e.handle && selected_handle != {} { // checking for empty handle here is unneccesary with break above
					rl.DrawLineV(p + size, mouse_position, rl.GREEN)
					connecting = true
				}
			}

			if !on_entity && !connecting && rl.IsMouseButtonPressed(.LEFT) {
				ha_add(&entities, Entity{
					position = (mouse_position - 15),
					color = rl.WHITE
				})
			}

			if rl.IsKeyPressed(.R) {
				regen_entities(&entities)
				connecting = false
				selected_handle = {}
			}


			for m, i in debug_message {
				rl.DrawText(m, 0, i32(i) * 10, 10, rl.YELLOW)
			}
			rl.DrawText("left click to connect or add entity, right click to remove, R to regen", 5, i32(windowsize.y) - 15, 10, rl.YELLOW)
		rl.EndDrawing()
	}
}

debug_message : [4]cstring