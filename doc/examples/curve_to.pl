use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        constant x=25.6;
        constant y=128.0;
        constant x1=102.4;
        constant y1=230.4;
        constant x2=153.6;
        constant y2=25.6;
        constant x3=230.4;
        constant y3=128.0;

        .move_to(x, y);
        .curve_to(x1, y1, x2, y2, x3, y3);

        .line_width = 10.0;
        .stroke;

        .rgba(1, 0.2, 0.2, 0.6);
        .line_width = 6.0;
        .move_to(x,y);   .line_to(x1,y1);
        .move_to(x2,y2); .line_to(x3,y3);
        .stroke;

    };
    .write_png("curve_to.png");
}

