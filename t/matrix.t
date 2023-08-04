use v6;
use Cairo;
use Test;

plan 14;

constant Matrix = Cairo::Matrix;
constant matrix_t = Cairo::cairo_matrix_t;

my $version = Cairo::version();
diag "Running cairo version: $version (module {Cairo.^ver}, Raku {$*RAKU.compiler.version})";

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
    given Cairo::Context.new($_) {

        my Matrix $identity-matrix .= new;
        is-deeply .matrix, Matrix.new.init(:xx(1e0), :yx(0e0), :xy(0e0), :yy(1e0), :x0(0e0), :y0(0e0)), 'identity';

        .translate(10,20);
        is-deeply .matrix, Matrix.new.init( :xx(1e0), :yy(1e0), :x0(10e0), :y0(20e0) ), 'translate';
        .save; {
            .scale(2, 3);
            is-deeply .matrix, Matrix.new.init( :xx(2e0), :yy(3e0), :x0(10e0), :y0(20e0) ), 'translate + scale';

            # http://zetcode.com/gfx/cairo/transformations/
            my Matrix $transform-matrix .= new.init( :xx(1), :yx(0.5),
                                                     :xy(0), :yy(1),
                                                     :x0(0), :y0(0) );
            .transform( $transform-matrix);
            is-deeply .matrix, Matrix.new.init( :xx(2e0), :yx(1.5e0), :yy(3e0), :x0(10e0), :y0(20e0) ), 'transform';
        };
        .restore;

        is-deeply .matrix, Matrix.new.init( :xx(1e0), :yy(1e0), :x0(10e0), :y0(20e0) ), 'save/restore';

        .identity_matrix;
        is-deeply .matrix, $identity-matrix, 'identity';

        my $prev-matrix = .matrix;
        .rotate(pi/2);
        my $rot-matrix = .matrix;
        is-deeply $prev-matrix, $identity-matrix, 'previous';
        is-approx $rot-matrix.yx, 1, 'rotated yx';
        is-approx $rot-matrix.xy, -1, 'rotated xy';

        my $matrix = Matrix.new.translate(10,20);
        is-deeply $matrix, Matrix.new.init( :xx(1e0), :yy(1e0), :x0(10e0), :y0(20e0) ), 'translate';

        $matrix.multiply: Matrix.new.scale(2,3);
        is-deeply $matrix, Matrix.new.init( :xx(2e0), :yy(3e0), :x0(20e0), :y0(60e0) ), 'multiply';

        $matrix.invert;
        is-approx $matrix.xx, 0.5, 'invert xx';
        is-approx $matrix.yy, 1/3, 'invert yy';
        is-approx $matrix.x0, -10, 'invert x0';
    };
};

done-testing;
