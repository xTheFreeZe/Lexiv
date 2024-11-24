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
@[minify]
pub struct App {
pub mut:
	site_to_render string
	gg             gg.Context
	db             sqlite.DB
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

	mut app := App{}
	app.db = db
	app.site_to_render = 'home'
	app.gg = gg.new_context(
		window_title: window_title
		width:        window_width
		height:       window_height
		bg_color:     gx.gray
		event_fn:     app.catch_event
		frame_fn:     frame
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

fn (mut app App) catch_event(event &gg.Event, _ voidptr) {
	match event.typ {
		.key_up {
			match event.key_code {
				.enter {
					app.site_to_render = 'home'
				}
				else {}
			}
		}
		.mouse_up {
			clicke_add, click_learn := check_if_mouse_on_text(event)

			if clicke_add {
				app.site_to_render = 'add_word'
			} else if click_learn {
				app.site_to_render = 'learn_word'
			}
		}
		else {}
	}
}

fn frame(mut app App) {
	app.draw_canvas()
}

fn (mut app App) draw_canvas() {
	app.gg.begin()
	match app.site_to_render.str() {
		'home' {
			app.draw_home()
		}
		'add_word' {
			app.draw_add_word()
		}
		'learn_word' {
			app.draw_learn_word()
		}
		else {
			app.gg.draw_rect_filled(0, 0, window_width, window_height, gx.white)
			app.gg.draw_text(370, 230, '404', gx.TextCfg{
				size:  60
				color: gx.red
			})
		}
	}
	app.gg.end()
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
