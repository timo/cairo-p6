use v6;
use Cairo;
use Test;

plan 9;

constant matrix_t = Cairo::cairo_matrix_t;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
    given Cairo::Context.new($_) {

        my matrix_t $identity-matrix .= new( :xx(1), :yy(1), );
        is-deeply .matrix, $identity-matrix, 'initial';

        .translate(10,20);
        is-deeply .matrix, matrix_t.new( :xx(1), :yy(1), :x0(10), :y0(20) ), 'translate';

        .save; {
            .scale(2, 3);
            is-deeply .matrix, matrix_t.new( :xx(2), :yy(3), :x0(10), :y0(20) ), 'translate + scale';

            # http://zetcode.com/gfx/cairo/transformations/
            my matrix_t $transform-matrix .= new( :xx(1), :yx(0.5),
                                                  :xy(0), :yy(1),
                                                  :x0(0), :y0(0) );
            .transform( $transform-matrix);
            is-deeply .matrix, matrix_t.new( :xx(2), :yx(1.5), :yy(3), :x0(10), :y0(20) ), 'transform';
        };
        .restore;

        is-deeply .matrix, matrix_t.new( :xx(1), :yy(1), :x0(10), :y0(20) ), 'save/restore';

        .identity_matrix;
        is-deeply .matrix, $identity-matrix, 'identity';

        my $prev-matrix = .matrix;
        .rotate(pi/2);
        my $rot-matrix = .matrix;
        is-deeply $prev-matrix, $identity-matrix, 'previous';
        is-approx $rot-matrix.yx, 1, 'rotated yx';
        is-approx $rot-matrix.xy, -1, 'rotated xy';
    };
};

done-testing;
