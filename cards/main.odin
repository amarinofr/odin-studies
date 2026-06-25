package main

import "core:fmt"
import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_W :: 800
SCREEN_H :: 800
ENTITY_UID :: distinct int

Entity :: struct {
	id:         ENTITY_UID,
	x, y, w, h: f32,
	color:      rl.Color,
}

Game_State :: struct {
	ui : struct {
		mouse_pos:        Vec2,
		collision:        bool,
		is_dragging:      bool,
		can_drop:         bool,
		point_of_contact: Vec2,
	},
	world:            struct {
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

	card_1.w = 150
	card_1.h = 200
	card_1.x = SCREEN_W / 2 - card_1.w / 2
	card_1.y = SCREEN_H / 2 - card_1.h / 2
	card_1.color = rl.RED

	pool.w = 760
	pool.h = 220
	pool.x = 20
	pool.y = 20
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
		gs.ui.point_of_contact = {gs.ui.mouse_pos.x - card_1.x, gs.ui.mouse_pos.y - card_1.y}
	}

	if rl.IsMouseButtonDown(.LEFT) && gs.ui.collision {
		gs.ui.is_dragging = true
		gs.ui.can_drop = false

		if rl.CheckCollisionRecs(card_1, pool) {
			gs.ui.can_drop = true
		}
	}

}

update :: proc() {
	if is_dragging {
		if is_within_bounds(gs.ui.mouse_pos.x, {0, SCREEN_W}) {
			card_1.x = gs.ui.mouse_pos.x - gs.ui.point_of_contact.x
		}
		if is_within_bounds(gs.ui.mouse_pos.y, {0, SCREEN_H}) {
			card_1.y = gs.ui.mouse_pos.y - gs.ui.point_of_contact.y
		}
	}

	if can_drop {
		card_1.color = rl.YELLOW

		if !is_dragging {
			card_1.x = pool.w / 2 - card_1.w / 2
			card_1.y = pool.h / 2 - card_1.h / 2 + pool.y
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
