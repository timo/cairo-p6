use v6;
use Cairo;

# adapted from https://zetcode.com/gfx/cairo/compositing/

sub do-drawing(Cairo::Context $ctx, Int $x, Int $w, Int $h, Int $op) {

    my Cairo::Image $blended-image .= create(Cairo::FORMAT_ARGB32, $w, $h);
    given Cairo::Context.new($blended-image) {
        .rgb(.5, .5, 0);
        .rectangle($x+10, 40, 50, 50);
        .fill;
    }
    my Cairo::Image $image .= create(Cairo::FORMAT_ARGB32, $w, $h);
    given Cairo::Context.new($image) {
        .rgb(0, 0, 0.4);
        .rectangle($x, 20, 50, 50);
        .fill;
        .operator = $op;
        .set_source_surface($blended-image, 0, 0);
        .paint;
    }
    $ctx.set_source_surface($image, 0, 0);
    $ctx.paint;

}

constant Width = 510;
constant Height = 120;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, Width, Height) {
    given Cairo::Context.new($_) {
        my @ops = (CAIRO_OPERATOR_DEST_OVER, 
                  CAIRO_OPERATOR_DEST_IN, 
                  CAIRO_OPERATOR_OUT,
                  CAIRO_OPERATOR_ADD, 
                  CAIRO_OPERATOR_ATOP,
                  CAIRO_OPERATOR_DEST_ATOP,
                 );

        my $x = 20;
        for @ops -> $op {
            do-drawing($_, $x, Width, Height, $op );
            $x += 80;
        }
    }
    .write_png("blend.png");
}
