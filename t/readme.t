use v6;
use Cairo;
use Test;

plan 1;

lives-ok {
    given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
        given Cairo::Context.new($_) {
            .rgb(0, 0.7, 0.9);
            .rectangle(10, 10, 50, 50);
            .fill :preserve; .rgb(1, 1, 1);
            .stroke
        };
        .write_png("foobar.png")
    }
};

unlink "foobar.png"; # don't care if failed

done-testing;
