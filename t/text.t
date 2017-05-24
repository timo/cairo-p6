use v6;
use Cairo;
use Test;

plan 8;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
    given Cairo::Context.new($_) {
        lives-ok {
            .move_to(10, 10);
            .select_font_face("courier", Cairo::FontSlant::FONT_SLANT_ITALIC, Cairo::FontWeight::FONT_WEIGHT_BOLD);
            .set_font_size(10);
            .show_text("Hello World");
        }
        my $font-extents = .font_extents;
        isa-ok $font-extents, Cairo::Context::FontExtents;
        is-approx $font-extents.ascent, 9, 'font extents ascent';
        is-approx $font-extents.descent, 3, 'font extents descent';
        is-approx $font-extents.height, 12, 'font extents height';

        my $text-extents = .text_extents("Hello World");
        isa-ok $text-extents, Cairo::Context::TextExtents;
        is-approx $text-extents.width, 67, 'text extents width';
        is-approx $text-extents.height, 7, 'text extents height';
    };
};

done-testing;
