module main

import gx

fn (mut app App) draw_home() {
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
