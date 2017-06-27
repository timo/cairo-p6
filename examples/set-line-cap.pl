use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        .line_width = 30.0;
        .line_cap = Cairo::LINE_CAP_BUTT; # default
        .move_to(64.0, 50.0); .line_to(64.0, 200.0);
        .stroke;
        .line_cap = Cairo::LINE_CAP_ROUND;
        .move_to(128.0, 50.0); .line_to(128.0, 200.0);
        .stroke;
        .line_cap = Cairo::LINE_CAP_SQUARE;
        .move_to(192.0, 50.0); .line_to(192.0, 200.0);
        .stroke;

        # draw helping lines */
        .rgb(1, 0.2, 0.2);
        .line_width = 2.56;
        .move_to(64.0, 50.0);  .line_to(64.0, 200.0);
        .move_to(128.0, 50.0); .line_to(128.0, 200.0);
        .move_to(192.0, 50.0); .line_to(192.0, 200.0);
        .stroke;

    };
    .write_png("set-line-cap.png");
}

