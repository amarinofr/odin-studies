package main

import "core:fmt"
import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_W :: 800
SCREEN_H :: 800
ENTITY_UID :: distinct int

Entity :: struct {
	id:    ENTITY_UID,
	rec:   rl.Rectangle,
	color: rl.Color,
}

Game_State :: struct {
	ui:    struct {
		mouse_pos:        Vec2,
		collision:        bool,
		is_dragging:      bool,
		can_drop:         bool,
		point_of_contact: Vec2,
	},
	world: struct {
		entities: [dynamic]Entity,
	},
}

card_1: Entity
pool: Entity

gs: ^Game_State

main :: proc() {
	rl.InitWindow(SCREEN_W, SCREEN_H, "Cards")
	rl.SetTargetFPS(60)
	defer (rl.CloseWindow())

	gs = new(Game_State)

	card_1.rec.width = 150
	card_1.rec.height = 200
	card_1.rec.x = SCREEN_W / 2 - card_1.rec.width / 2
	card_1.rec.y = SCREEN_H / 2 - card_1.rec.height / 2
	card_1.color = rl.RED

	pool.rec.width = 760
	pool.rec.height = 220
	pool.rec.x = 20
	pool.rec.y = 20
	pool.color = rl.GREEN

	for !rl.WindowShouldClose() {
		input()
		update()
		render()
	}
}

is_within_bounds :: proc(el_pos: f32, el_bounds: [2]f32) -> bool {
	check: bool
	if el_pos >= el_bounds.x && el_pos <= el_bounds.y {
		check = true
	}
	return check
}

input :: proc() {
	gs.ui.mouse_pos = rl.GetMousePosition()

	if rl.IsMouseButtonReleased(.LEFT) {
		gs.ui.is_dragging = false
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		gs.ui.collision = rl.CheckCollisionPointRec(gs.ui.mouse_pos, card_1.rec)
		gs.ui.point_of_contact = {
			gs.ui.mouse_pos.x - card_1.rec.x,
			gs.ui.mouse_pos.y - card_1.rec.y,
		}
	}

	if rl.IsMouseButtonDown(.LEFT) && gs.ui.collision {
		gs.ui.is_dragging = true
		gs.ui.can_drop = false

		if rl.CheckCollisionRecs(card_1.rec, pool.rec) {
			gs.ui.can_drop = true
		}
	}

}

update :: proc() {
	if gs.ui.is_dragging {
		if is_within_bounds(gs.ui.mouse_pos.x, {0, SCREEN_W}) {
			card_1.rec.x = gs.ui.mouse_pos.x - gs.ui.point_of_contact.x
		}
		if is_within_bounds(gs.ui.mouse_pos.y, {0, SCREEN_H}) {
			card_1.rec.y = gs.ui.mouse_pos.y - gs.ui.point_of_contact.y
		}
	}

	if gs.ui.can_drop {
		card_1.color = rl.YELLOW

		if !gs.ui.is_dragging {
			card_1.rec.x = pool.rec.width / 2 - card_1.rec.width / 2
			card_1.rec.y = pool.rec.height / 2 - card_1.rec.height / 2 + pool.rec.y
			card_1.color = rl.BLUE
		}
	} else {
		card_1.color = rl.RED
	}
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.DrawFPS(30, 770)

	rl.DrawRectangleRec(pool.rec, pool.color)
	rl.DrawRectangleRec(card_1.rec, card_1.color)

	rl.EndDrawing()
}
