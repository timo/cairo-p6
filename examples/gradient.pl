use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        my Cairo::Pattern::Gradient::Linear $lpat .= create(0.0, 0.0,  0.0, 256.0);
        $lpat.add_color_stop_rgba(1, 0, 0, 0, 1);
        $lpat.add_color_stop_rgba(0, 1, 1, 1, 1);
        .rectangle(0, 0, 256, 256);
        .pattern($lpat);
        .fill;
        $lpat.destroy;

        my Cairo::Pattern::Gradient::Radial $rpat .= create(115.2, 102.4, 25.6,
                                                            102.4,  102.4, 128.0);
        $rpat.add_color_stop_rgba(0, 1, 1, 1, 1);
        $rpat.add_color_stop_rgba(1, 0, 0, 0, 1);
        .pattern($rpat);
        .arc(128.0, 128.0, 76.8, 0, 2 * pi);
        .fill;
        $rpat.destroy;

    };
    .write_png("gradient.png");
}

