use v6;
use Cairo;

constant xc = 128.0;
constant yc = 128.0;
constant radius = 100.0;
constant angle1 = 45.0  * (pi/180.0);  # angles are specified
constant angle2 = 180.0 * (pi/180.0); # in radians

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {
        .arc(128.0, 128.0, 76.8, 0, 2*pi);
        .clip;
        .new_path; # path not consumed by .clip

        my \image = Cairo::Image.open("examples/camelia.png" );
        my \w = image.width;
        my \h = image.height;

        .scale(256.0/w, 256.0/h);

        .set_source_surface(image, 0, 0);
        .paint;

        image.destroy;
    };
    .write_png("clip-image.png");
}

