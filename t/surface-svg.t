use v6;
use Cairo;
use Test;

plan 6;

lives-ok {
    given Cairo::Surface::SVG.create("foobar.svg", 128, 128) {
        is .width, 128, 'width';
        is .height, 128, 'height';
        given Cairo::Context.new($_) {
            .rgb(0, 0.7, 0.9);
            .rectangle(10, 10, 50, 50);
            .fill :preserve; .rgb(1, 1, 1);
            .stroke
        };
        .finish;
        ok "foobar.svg".IO.e, "svg created";
    }
};

lives-ok {
    my Cairo::Surface::SVG $svg .= new: :filename<foo2.svg>, :width(128), :height(64);
    $svg.finish;
}
ok "foo2.svg".IO.e, "svg created from new";

unlink "foobar.svg"; # don't care if failed
unlink "foo2.svg"; # don't care if failed

done-testing;
