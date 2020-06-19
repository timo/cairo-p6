use v6;
use Cairo;

constant xc = 128.0;
constant yc = 128.0;
constant radius = 100.0;
constant angle1 = 45.0  * (pi/180.0);  # angles are specified
constant angle2 = 180.0 * (pi/180.0); # in radians

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {
        .line_width = 10.0;
        .arc(xc, yc, radius, angle1, angle2, :negative);
        .stroke;

        # draw helping lines
        .rgba(1, 0.2, 0.2, 0.6);
        .line_width = 6.0;

        .arc(xc, yc, 10.0, 0, 2*pi);
        .fill;

        .arc(xc, yc, radius, angle1, angle1);
        .line_to(xc, yc);
        .arc(xc, yc, radius, angle2, angle2);
        .line_to(xc, yc);
        .stroke;
    };
    .write_png("arc-negative.png");
}

