module main

import gg
import gx
import term
import time
import db.sqlite

const window_width = 800
const window_height = 600
const window_title = 'Lexiv'

struct Vocabulary {
	id            int @[primary; sql: 'serial']
	word          string
	added_at      time.Time @[default: 'CURRENT_TIME']
	last_reviewed time.Time @[sql_type: 'TIMESTAMP']
}

// Store this on the heap as it's a large struct
@[heap]
struct App {
mut:
	gg gg.Context
pub mut:
	db &sqlite.DB
}

fn main() {
	mut db := sqlite.connect('lexiv.db') or {
		err_db := term.red('Failed to connect to database "lexiv.db"')
		println('${err_db} \n\n${err}')
		exit(1)
	}

	println(term.green('Connected to database "lexiv.db"'))

	defer {
		db.close() or {
			err_db := term.red('Failed to close database "lexiv.db"')
			println('${err_db} \n\n${err}')
			exit(1)
		}
		println(term.green('Database "lexiv.db" closed'))
	}

	mut app := &App{
		db: &db
	}
	app.gg = gg.new_context(
		window_title: window_title
		width:    window_width
		height:   window_height
		bg_color: gx.gray
		event_fn: catch_event
		frame_fn: frame
	)

	sql app.db {
		create table Vocabulary
	} or {
		err_db := term.red('Failed to create table "Vocabulary"')
		println('${err_db} \n\n${err}')
		exit(1)
	}

	app.gg.run()
}

fn catch_event(event &gg.Event, mut app App) {
	match event.typ {
		.key_up {
			match event.key_code {
				.enter {
					println('Enter key pressed')
				}
				else {}
			}
		}
		.mouse_up {
			clicke_add, click_learn := check_if_mouse_on_text(event)

			if clicke_add {
				println('Add a word clicked')
			} else if click_learn {
				println('Review words clicked')
			}
		}
		else {}
	}
}

fn frame(mut app App) {
	app.gg.begin()
	app.draw_canvas()
	app.gg.end()
}

fn (mut app App) draw_canvas() {
	add_color, mut learn_color := gx.black, gx.black

	app.gg.draw_text(370, 230, 'Lexiv', gx.TextCfg{
		size:  60
		color: gx.blue
	})

	app.gg.draw_text(170, 400, 'Add words', gx.TextCfg{
		size:  30
		color: add_color
		bold:  true
	})

	app.gg.draw_text(570, 400, 'Learn words', gx.TextCfg{
		size:  30
		color: learn_color
		bold:  true
	})
}

// I don't know if there is a way to add event listeners in gx
// So I'm just going to check if the mouse is on the text in the event function
fn check_if_mouse_on_text(event &gg.Event) (bool, bool) {
	x, y := event.mouse_x, event.mouse_y

	if x >= 170 && x <= 270 && y >= 400 && y <= 430 {
		return true, false
	} else if x >= 570 && x <= 670 && y >= 400 && y <= 430 {
		return false, true
	} else {
		return false, false
	}
}
