package main

import "core:fmt"
import rl "vendor:raylib"

Vec2 :: [2]f32

SCREEN_W :: 800
SCREEN_H :: 800

mouse_pos: Vec2
collision: bool
is_dragging: bool
point_of_contact: Vec2

card :: struct {
	using rec: rl.Rectangle,
	color:     rl.Color,
}

card_1: card

main :: proc() {
	rl.InitWindow(SCREEN_W, SCREEN_H, "Cards")
	rl.SetTargetFPS(60)
	defer (rl.CloseWindow())

	card_1.width = 150
	card_1.height = 200
	card_1.x = SCREEN_W / 2 - card_1.width / 2
	card_1.y = SCREEN_H / 2 - card_1.height / 2
	card_1.color = rl.RED

	for !rl.WindowShouldClose() {
		input()
		update()
		render()
	}
}

is_within_bounds :: proc(el_pos, threshold: f32, el_bounds: [2]f32) -> bool {
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
		point_of_contact = {mouse_pos.x - card_1.x, mouse_pos.y - card_1.y}
	}

	if rl.IsMouseButtonDown(.LEFT) && collision {
		is_dragging = true
	}
}

update :: proc() {
	if is_dragging {
		if is_within_bounds(mouse_pos.x, 0, {0, SCREEN_W}) {
			card_1.x = mouse_pos.x - point_of_contact.x
		}
		if is_within_bounds(mouse_pos.y, 0, {0, SCREEN_H}) {
			card_1.y = mouse_pos.y - point_of_contact.y
		}
	}
}

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rl.DrawFPS(30, 770)

	rl.DrawRectangleRec(card_1.rec, card_1.color)


	rl.EndDrawing()
}
