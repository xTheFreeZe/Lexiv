module main

import ui
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
	window &ui.Window = unsafe { nil }
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

	sql app.db {
		create table Vocabulary
	} or {
		err_db := term.red('Failed to create table "Vocabulary"')
		println('${err_db} \n\n${err}')
		exit(1)
	}

	app.window = ui.window(
		width:    window_width
		height:   window_height
		title:    window_title
		children: [
			ui.column(
				alignments: ui.HorizontalAlignments{
					center: [
						0,
					]
					right:  [
						1,
					]
				}
				widths:     [
					ui.stretch,
					ui.compact,
				]
				heights:    [
					ui.stretch,
					100.0,
				]
				children:   [
					ui.canvas(
						width:   window_width
						height:  window_height + 100
						draw_fn: app.draw_canvas
					),
				]
			),
		]
	)

	ui.run(app.window)
}

fn (app &App) draw_canvas(gg_ &gg.Context, c &ui.Canvas) {
	gg_.draw_rect_filled(c.x, 0, c.width, c.height, gx.black)
	gg_.draw_text(c.x / 2, c.y / 2, 'Hello, world!', gx.TextCfg{
		size:  48
		color: gx.white
	})
}
