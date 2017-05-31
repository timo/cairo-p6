use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        .line_width = 40.96;
        .move_to(76.8, 84.48);
        .line_to(51.2, -51.2, :relative);
        .line_to(51.2, 51.2, :relative);
        .line_join = Cairo::LineJoin::LINE_JOIN_MITER; # default
        .stroke;

        .move_to(76.8, 161.28);
        .line_to(51.2, -51.2, :relative);
        .line_to(51.2, 51.2, :relative);
        .line_join = Cairo::LineJoin::LINE_JOIN_BEVEL;
        .stroke;

        .move_to(76.8, 238.08);
        .line_to(51.2, -51.2, :relative);
        .line_to(51.2, 51.2, :relative);
        .line_join = Cairo::LineJoin::LINE_JOIN_ROUND;
        .stroke;

    };
    .write_png("set-line-join.png");
}

