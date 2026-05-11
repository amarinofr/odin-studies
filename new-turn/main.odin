package main

import "core:fmt"
import "core:os"
import "core:sys/linux"
import "core:sys/posix"

Vec2 :: [2]int

win :: struct {
	row, col: u16,
	x, y:     u16,
}

Player :: struct {
	pos, dir: Vec2,
}

game_state :: struct {
	window:  win,
	og_mode: posix.termios,
	pfd:     [1]posix.pollfd,
	player:  Player,
}

gs: ^game_state

main :: proc() {
	gs = new(game_state)
	linux.ioctl(cast(linux.Fd)(posix.STDOUT_FILENO), linux.TIOCGWINSZ, uintptr(&gs.window))

	gs.pfd[0].fd = posix.STDIN_FILENO
	gs.pfd[0].events = {.IN}
	gs.player.pos = {1, 2}

	res := posix.tcgetattr(posix.STDIN_FILENO, &gs.og_mode)
	defer (posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &gs.og_mode))
	assert(res == .OK)

	new_mode := gs.og_mode
	new_mode.c_lflag -= {.ECHO, .ICANON}
	res = posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &new_mode)
	assert(res == .OK)

	loop: for {
		input(&gs.pfd)
		update()
		render()
	}
}

input :: proc(pfd: ^[1]posix.pollfd) {
	poll := posix.poll(raw_data(pfd[:]), u64(len(pfd[:])), 16)
	seq: [3]byte

	if poll > 0 {
		n := posix.read(posix.STDIN_FILENO, raw_data(seq[:]), 3)

		if n > 0 {
			if seq[0] == 27 {
				if n == 1 {
					fmt.println("Quitting")
					os.exit(-1)
				}
				if n == 3 {
					switch seq[2] {
					case 65:
						// fmt.println("up")
						update_pos(&gs.player.pos, {0, -1})
					case 66:
						// fmt.println("down")
						update_pos(&gs.player.pos, {0, 1})
					case 67:
						// fmt.println("right")
						update_pos(&gs.player.pos, {1, 0})
					case 68:
						// fmt.println("left")
						update_pos(&gs.player.pos, {-1, 0})
					}
				}
			} else {
				switch seq[0] {
				case 32:
				// fmt.println("SPACE")
				case 10:
				// fmt.println("ENTER")
				}
			}
		}
	}
}

update_pos :: proc(pos: ^Vec2, dir: Vec2) {
	if pos.x >= 1 && pos.x <= int(gs.window.col) {
		pos.x += dir.x

		if pos.x >= int(gs.window.col) do pos.x = int(gs.window.col)
		if pos.x < 1 do pos.x = 1
	}
	if pos.y >= 2 && pos.y <= int(gs.window.row) {
		pos.y += dir.y

		if pos.y >= int(gs.window.row) do pos.y = int(gs.window.row)
		if pos.y < 2 do pos.y = 2
	}
}

update :: proc() {

}

render :: proc() {
	fmt.print("\x1b[2J\x1b[H\x1b[?25l")
	// fmt.println("Game running...")

	fmt.printf("%d ROWS x %d COLS ", gs.window.row, gs.window.col)
	fmt.printf("| x: %d y: %d", gs.player.pos.x, gs.player.pos.y)

	fmt.printf("\x1b[%d;%dH", gs.player.pos.y, gs.player.pos.x)
	fmt.print("@")
}
