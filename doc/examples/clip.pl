use v6;
use Cairo;

constant xc = 128.0;
constant yc = 128.0;
constant radius = 100.0;
constant angle1 = 45.0  * (pi/180.0);  # angles are specified
constant angle2 = 180.0 * (pi/180.0); # in radians

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {
        .arc(128.0, 128.0, 76.8, 0, 2 * pi);
        .clip();

        .new_path();  # current path is not
                      # consumed by .clip
        .rectangle(0, 0, 256, 256);
        .fill();
        .rgb(0, 1, 0);
        .move_to(0, 0);
        .line_to(256, 256);
        .move_to(256, 0);
        .line_to(0, 256);
        .line_width = 10.0;
        .stroke();
    };
    .write_png("clip.png");
}

