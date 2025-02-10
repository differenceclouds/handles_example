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


main :: proc() {
	windowsize = {640, 480}
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(i32(windowsize.x), i32(windowsize.y), "handle this")


	entities: Handle_Array(Entity, EntityHandle)

	for i := 0; i < 50; i += 1 {
		x := rand.float32() * (windowsize.x - 30)
		y := rand.float32() * (windowsize.y - 30)
		ha_add(&entities, Entity{
			position = {x, y},
			color = rl.WHITE
		})
	}

	selected_handle: EntityHandle


	for !rl.WindowShouldClose() {

		mouse_position := rl.GetMousePosition()
		// debug_message[0] = fmt.ctprint(mouse_position)

		if rl.IsWindowResized() {
			windowsize = {f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
		}



		rl.BeginDrawing()
			rl.ClearBackground(0)

			on_entity: bool

			ee := ha_make_iter(entities)
			size: [2]f32 = {30, 15}
			for e in ha_iter_ptr(&ee) {
				p := e.position
				color := e.color
				if mouse_position.x >= p.x && mouse_position.x < p.x + size.x &&
				mouse_position.y >= p.y && mouse_position.y < p.y + size.y {
					on_entity = true
					rl.DrawRectangleV(p - 2, size + 4, rl.RED)
					if rl.IsMouseButtonPressed(.LEFT) {

						if selected_handle == {} {
							selected_handle = e.handle
							e.connected_to = {}
						} else {
							selected_entity := ha_get_ptr(entities, selected_handle)
							selected_entity.connected_to = e.handle
							selected_handle = {}
						}
					}
					if rl.IsMouseButtonPressed(.RIGHT) {
						ha_remove(&entities, e.handle)
					}
				}
				rl.DrawRectangleV(p, size, color)
				rl.DrawText(fmt.ctprintf("%v, %v", e.handle.idx, e.handle.gen), i32(p.x) + 2, i32(p.y) + 2, 10, rl.BLACK)


				if connected_to, ok := ha_get(entities, e.connected_to) ; ok {
					rl.DrawLineV(p + size, connected_to.position, rl.GREEN)
					rl.DrawCircleV(connected_to.position, 4, rl.RED)
				} else if selected_handle == e.handle {
					rl.DrawLineV(p + size, mouse_position, rl.GREEN)
				}
			}

			if !on_entity && rl.IsMouseButtonPressed(.LEFT) {
				ha_add(&entities, Entity{
					position = (mouse_position - 15),
					color = rl.WHITE
				})
			}

			if rl.IsKeyPressed(.R) {
				ha_clear(&entities)
				for i := 0; i < 50; i += 1 {
					x := rand.float32() * (windowsize.x - size.x)
					y := rand.float32() * (windowsize.y - 30)
					ha_add(&entities, Entity{
						position = {x, y},
						color = rl.WHITE
					})
				}
			}


			for m, i in debug_message {
				rl.DrawText(m, 0, i32(i) * 10, 10, rl.YELLOW)
			}
			rl.DrawText("left click to connect or add entity, right click to remove, R to regen", 5, i32(windowsize.y) - 15, 10, rl.YELLOW)
		rl.EndDrawing()
	}
}

debug_message : [4]cstring