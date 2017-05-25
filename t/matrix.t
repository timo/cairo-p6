use v6;
use Cairo;
use Test;

plan 9;

constant matrix_t = Cairo::cairo_matrix_t;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
    given Cairo::Context.new($_) {

        my matrix_t $identity-matrix .= new( :xx(1e0), :yy(1e0), );
        is-deeply .matrix, $identity-matrix, 'initial';

        .translate(10,20);
        is-deeply .matrix, matrix_t.new( :xx(1e0), :yy(1e0), :x0(10e0), :y0(20e0) ), 'translate';

        .save; {
            .scale(2e0, 3e0);
            is-deeply .matrix, matrix_t.new( :xx(2e0), :yy(3e0), :x0(10e0), :y0(20e0) ), 'translate + scale';

            # http://zetcode.com/gfx/cairo/transformations/
            my matrix_t $transform-matrix .= new( :xx(1e0), :yx(0.5e0),
                                                  :xy(0e0), :yy(1e0),
                                                  :x0(0e0), :y0(0e0) );
            .transform( $transform-matrix);
            is-deeply .matrix, matrix_t.new( :xx(2e0), :yx(1.5e0), :yy(3e0), :x0(10e0), :y0(20e0) ), 'transform';
        };
        .restore;

        is-deeply .matrix, matrix_t.new( :xx(1e0), :yy(1e0), :x0(10e0), :y0(20e0) ), 'save/restore';

        .identity_matrix;
        is-deeply .matrix, $identity-matrix, 'identity';

        my $prev-matrix = .matrix;
        .rotate(pi/2);
        my $rot-matrix = .matrix;
        is-deeply $prev-matrix, $identity-matrix, 'previous';
        is-approx $rot-matrix.yx, 1e0, 'rotated yx';
        is-approx $rot-matrix.xy, -1e0, 'rotated xy';
    };
};

done-testing;
