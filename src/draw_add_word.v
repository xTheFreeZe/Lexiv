module main

import gx

fn (mut app App) draw_add_word() {
	app.gg.draw_rect_filled(0, 0, window_width, window_height, gx.gray)

	app.gg.draw_text(10, 10, 'Add words', gx.TextCfg{
		size:  60
		color: gx.blue
	})

	app.gg.draw_text(10, 100, 'Press "Enter" to go back', gx.TextCfg{
		size:  30
		color: gx.black
	})
}
