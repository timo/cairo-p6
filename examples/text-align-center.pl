use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        .select_font_face("Sans",
                          Cairo::FontSlant::FONT_SLANT_NORMAL,
                          Cairo::FontWeight::FONT_WEIGHT_BOLD);
        .set_font_size(52.0);

        my \text = "cairo";
        my Cairo::cairo_text_extents_t \extents = .text_extents(text);
        my \x = 128.0-(extents.width/2 + extents.x_bearing);
        my \y = 128.0-(extents.height/2 + extents.y_bearing);

        .move_to(x, y);
        .show_text(text);

        # draw helping lines
        .rgba(1, 0.2, 0.2, 0.6);
        .line_width = 6.0;
        .arc(x, y, 10.0, 0, 2*pi);
        .fill;
        .move_to(128.0, 0);
        .line_to(0, 256, :relative);
        .move_to(0, 128.0);
        .line_to(256, 0, :relative);
        .stroke;
    };
    .write_png("text-align-center.png");
}

