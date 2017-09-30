use v6;
use Cairo;
use Test;

plan 7;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
    given Cairo::Context.new($_) {
        lives-ok {
            .move_to(10, 10);
            .select_font_face("courier", Cairo::FontSlant::FONT_SLANT_ITALIC, Cairo::FontWeight::FONT_WEIGHT_BOLD);
            .set_font_size(10);
            .show_text("Hello World");
        }
        # issue #11 actual chosen font is system dependant
        my $font-extents = .font_extents;
        isa-ok $font-extents, Cairo::cairo_font_extents_t;
        ok 7 < $font-extents.ascent < 12, 'font extents ascent'
            or diag "got ascent: {$font-extents.ascent}";

        my $text-extents = .text_extents("Hello World");
        isa-ok $text-extents, Cairo::cairo_text_extents_t;
        ok 60 < $text-extents.width < 75, 'text extents width'
            or diag "got width: {$text-extents.width}";
        ok 5 < $text-extents.height < 9, 'text extents height'
            or diag "got height: {$text-extents.height}";
    };
    lives-ok {.Blob}, '.Blob';
};

done-testing;
