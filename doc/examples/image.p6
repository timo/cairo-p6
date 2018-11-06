use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        my \image = Cairo::Image.open("camelia.png" );
        my \w = image.width;
        my \h = image.height;

        .translate(128.0, 128.0);
        .rotate(30 * pi/180);
        .scale(256/w, 256/h);
        .translate(-0.5*w, -0.5*h);

        .set_source_surface(image, 0, 0);
        .paint;
        image.destroy;

    };
    .write_png("image.png");
}

