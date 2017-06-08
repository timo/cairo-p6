use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        .select_font_face("Sans",
                          Cairo::FontSlant::FONT_SLANT_NORMAL,
                          Cairo::FontWeight::FONT_WEIGHT_NORMAL);
        .set_font_size(100.0);

        my \text = "cairo";
        my Cairo::cairo_text_extents_t \extents = .text_extents(text);
        constant x=25.0;
        constant y=150.0;

        .move_to(x,y);
        .show_text(text);

        # draw helping lines
        .rgba(1, 0.2, 0.2, 0.6);
        .line_width = 6.0;
        .arc(x, y, 10.0, 0, 2*pi);
        .fill;
        .move_to(x,y);
        .line_to(0, -extents.height, :relative);
        .line_to(extents.width, 0, :relative);
        .line_to(extents.x_bearing, -extents.y_bearing, :relative);
        .stroke;
    };
    .write_png("text-extents.png");
}

