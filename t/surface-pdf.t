use v6;
use Cairo;
use Test;

plan 4;

lives-ok {
    given Cairo::Surface::PDF.create("foobar.pdf", 128, 128) {
        is .width, 128, 'width';
        is .height, 128, 'height';
        given Cairo::Context.new($_) {
            .rgb(0, 0.7, 0.9);
            .rectangle(10, 10, 50, 50);
            .fill :preserve; .rgb(1, 1, 1);
            .stroke
        };
        .show_page;
        .finish;
        ok "foobar.pdf".IO.e, "pdf created";
    }
};

unlink "foobar.pdf"; # don't care if failed

done-testing;
