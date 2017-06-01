use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        constant x         = 25.6;        # parameters like cairo_rectangle
        constant y         = 25.6;
        constant width     = 204.8;
        constant height    = 204.8;
        constant aspect    = 1.0;     # aspect ratio
        constant corner_radius = height / 10.0;   # and corner curvature radius
        constant radius = corner_radius / aspect;
        constant degrees = pi / 180.0;

        .sub_path;
        .arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
        .arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
        .arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
         .arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
        .close_path;

        .rgb(0.5, 0.5, 1);
        .fill(:preserve);
        .rgba(0.5, 0, 0, 0.5);
        .line_width = 10;
        .stroke;

    };
    .write_png("rounded-rectangle.png");
}

