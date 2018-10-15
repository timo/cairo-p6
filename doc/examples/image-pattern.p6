use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        my $image = Cairo::Image.open("examples/camelia.png" );
        my \w = $image.width;
        my \h = $image.height;

        my Cairo::Pattern::Surface $pattern .= create($image.surface);
        $pattern.extend = Cairo::EXTEND_REPEAT;

        .translate(128.0, 128.0);
        .rotate(pi / 4);
        .scale(1 / sqrt(2), 1 / sqrt(2));
        .translate(-128.0, -128.0);

        my Cairo::Matrix $matrix .= new.scale(w/256.0 * 5.0, h/256.0 * 5.0);
        $pattern.matrix = $matrix;
        .pattern($pattern);

        .rectangle(0, 0, 256.0, 256.0);
        .fill;

        $pattern.destroy;
        $image.destroy;

    };
    .write_png("image-pattern.png");
}

