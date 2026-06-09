package main

import "core:fmt"
import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_W :: 800
SCREEN_H :: 800

mouse_pos: Vec2
collision: bool
is_dragging: bool
point: Vec2

card :: struct {
	using rec: rl.Rectangle,
	color:     rl.Color,
}

card_1: card

main :: proc() {
	rl.InitWindow(SCREEN_W, SCREEN_H, "Cards")
	rl.SetTargetFPS(60)
	defer (rl.CloseWindow())

	card_1.width = 300
	card_1.height = 400
	card_1.x = SCREEN_W / 2 - card_1.width / 2
	card_1.y = SCREEN_H / 2 - card_1.height / 2
	card_1.color = rl.RED

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		input()
		update()
		render()

		rl.EndDrawing()
	}
}

is_within_bounds :: proc(el_pos: f32, threshold: f32) -> bool {
	check: bool

	if el_pos - threshold >= 0 && el_pos + threshold <= SCREEN_W {
		check = true
	}

	return check
}

input :: proc() {
	mouse_pos = rl.GetMousePosition()

	if rl.IsMouseButtonReleased(.LEFT) {
		is_dragging = false
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		collision = rl.CheckCollisionPointRec(mouse_pos, card_1.rec)
		point = {mouse_pos.x - card_1.x, mouse_pos.y - card_1.y}

		if rl.IsMouseButtonDown(.LEFT) && collision {
			is_dragging = true
		}
	}
}

update :: proc() {
	if is_dragging {
		if is_within_bounds(mouse_pos.x, 25) {
			card_1.x = mouse_pos.x - point.x
		}
		if is_within_bounds(mouse_pos.y, 25) {
			card_1.y = mouse_pos.y - point.y
		}
	}
}

render :: proc() {
	rl.DrawRectangleRec(card_1.rec, card_1.color)
}
