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

	gs.pfd[0].fd = posix.STDIN_FILENO
	gs.pfd[0].events = {.IN}
	gs.player.pos = {1, 2}

	res := posix.tcgetattr(posix.STDIN_FILENO, &gs.og_mode)
	assert(res == .OK)
	new_mode := gs.og_mode
	new_mode.c_lflag -= {.ECHO, .ICANON}

	res = posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &new_mode)
	defer (posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &gs.og_mode))
	assert(res == .OK)
	loop: for {
		input(&gs.pfd)
		update()
		render()
	}
}

input :: proc(pfd: ^[1]posix.pollfd) {
	poll := posix.poll(raw_data(pfd[:]), u64(len(pfd[:])), 16)
	buf: [3]byte

	if poll > 0 {
		n := posix.read(posix.STDIN_FILENO, raw_data(buf[:]), 3)

		if n > 0 {
			if buf[0] == 27 {
				if n == 1 {
					fmt.println("Quitting")
					os.exit(-1)
				}
				if n == 3 {
					switch buf[2] {
					case 65:
						// UP
						gs.player.dir = {0, -1}
					case 66:
						// DOWN
						gs.player.dir = {0, 1}
					case 67:
						// RIGHT
						gs.player.dir = {1, 0}
					case 68:
						// LEFT
						gs.player.dir = {-1, 0}
					}
				}
			} else {
				switch buf[0] {
				case 32:
				// SPACE
				case 10:
				// ENTER
				}
			}
		}
	}
}

update_pos :: proc() {
	if gs.player.pos.x >= 1 &&
	   gs.player.pos.x <= int(gs.window.col) &&
	   gs.player.pos.y >= 2 &&
	   gs.player.pos.y <= int(gs.window.row) {
		gs.player.pos += gs.player.dir

		if gs.player.pos.x >= int(gs.window.col) do gs.player.pos.x = int(gs.window.col)
		if gs.player.pos.x < 1 do gs.player.pos.x = 1
		if gs.player.pos.y >= int(gs.window.row) do gs.player.pos.y = int(gs.window.row)
		if gs.player.pos.y < 2 do gs.player.pos.y = 2
	}
}

update :: proc() {
	update_pos()
	gs.player.dir = {0, 0}
}

render :: proc() {
	linux.ioctl(cast(linux.Fd)(posix.STDOUT_FILENO), linux.TIOCGWINSZ, uintptr(&gs.window))

	fmt.print("\x1b[2J\x1b[H\x1b[?25l")

	fmt.printf("%d ROWS x %d COLS ", gs.window.row, gs.window.col)
	fmt.printf("| x: %d y: %d ", gs.player.pos.x, gs.player.pos.y)
	fmt.printf("| dir x: %d, dir y: %d", gs.player.dir.x, gs.player.dir.y)

	fmt.printf("\x1b[%d;%dH", gs.player.pos.y, gs.player.pos.x)
	fmt.print("@")
}
