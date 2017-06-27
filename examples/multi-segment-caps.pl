use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        .move_to(50.0, 75.0);
        .line_to(200.0, 75.0);

        .move_to(50.0, 125.0);
        .line_to(200.0, 125.0);

        .move_to(50.0, 175.0);
        .line_to(200.0, 175.0);

        .line_width = 30.0;
        .line_cap = Cairo::LINE_CAP_ROUND;
        .stroke;

    };
    .write_png("multi-segment-caps.png");
}

