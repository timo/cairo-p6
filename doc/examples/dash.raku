use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        my \dashes = (50.0,  # ink
                      10.0,  # skip
                      10.0,  # ink
                      10.0   # skip
            );
        my \ndash  = +dashes;
        my \offset = -50.0;

        .set_dash(dashes, ndash, offset);
        .line_width = 10.0;

        .move_to(128.0, 25.6);
        .line_to(230.4, 230.4);
        .line_to(-102.4, 0.0, :relative);
        .curve_to(51.2, 230.4, 51.2, 128.0, 128.0, 128.0);

        .stroke;
    };
    .write_png("dash.png");
}

