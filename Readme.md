Cairo 2D Graphics library binding for Perl 6
============================================

Synopsis
--------

    use Cairo;
    given Cairo::Image.create(FORMAT_ARGB32, 128, 128) {
        given Cairo::Context.new($_) {
            .rgb(0, 0.7, 0.9);
            .rectangle(10, 10, 50, 50);
            .fill :preserve; .rgb(1, 1, 1);
            .stroke
        };
        .write_png("foobar.png")
    }


