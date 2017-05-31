use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {
        .move_to(128.0, 25.6);
        .line_to(230.4, 230.4);
        .line_to(-102.4, 0.0, :relative);
        .curve_to(51.2, 230.4, 51.2, 128.0, 128.0, 128.0);
        .close_path;

        .move_to(64.0, 25.6);
        .line_to(51.2, 51.2, :relative);
        .line_to(-51.2, 51.2, :relative);
        .line_to(-51.2, -51.2, :relative);
        .close_path;

        .line_width = 10.0;
        .rgb(0, 0, 1);
        .fill(:preserve);
        .rgb(0, 0, 0);
        .stroke;
    };
    .write_png("fill-and-stroke.png");
}

