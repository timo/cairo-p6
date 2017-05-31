use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {
        # a custom shape that could be wrapped in a function
        constant x0      = 25.6;   # parameters like cairo_rectangle
        constant y0      = 25.6;
        constant rect_width  = 204.8;
        constant rect_height = 204.8;
        constant radius = 102.4 * 2;   # and an approximate curvature radius

        constant x1 = x0 + rect_width;
        constant y1 = y0 + rect_height;

        if (!rect_width || !rect_height) {
            return;
        }
        if (rect_width/2 < radius) {
            if (rect_height/2 < radius) {
                .move_to(x0, (y0 + y1)/2);
                .curve_to(x0 ,y0, x0, y0, (x0 + x1)/2, y0);
                .curve_to(x1, y0, x1, y0, x1, (y0 + y1)/2);
                .curve_to(x1, y1, x1, y1, (x1 + x0)/2, y1);
                .curve_to(x0, y1, x0, y1, x0, (y0 + y1)/2);
            } else {
                .move_to(x0, y0 + radius);
                .curve_to(x0 ,y0, x0, y0, (x0 + x1)/2, y0);
                .curve_to(x1, y0, x1, y0, x1, y0 + radius);
                .line_to(x1 , y1 - radius);
                .curve_to(x1, y1, x1, y1, (x1 + x0)/2, y1);
                .curve_to(x0, y1, x0, y1, x0, y1- radius);
            }
        } else {
            if (rect_height/2 < radius) {
                .move_to(x0, (y0 + y1)/2);
                .curve_to(x0 , y0, x0 , y0, x0 + radius, y0);
                .line_to(x1 - radius, y0);
                .curve_to(x1, y0, x1, y0, x1, (y0 + y1)/2);
                .curve_to(x1, y1, x1, y1, x1 - radius, y1);
                .line_to(x0 + radius, y1);
                .curve_to(x0, y1, x0, y1, x0, (y0 + y1)/2);
            } else {
                .move_to(x0, y0 + radius);
                .curve_to(x0 , y0, x0 , y0, x0 + radius, y0);
                .line_to(x1 - radius, y0);
                .curve_to(x1, y0, x1, y0, x1, y0 + radius);
                .line_to(x1 , y1 - radius);
                .curve_to(x1, y1, x1, y1, x1 - radius, y1);
                .line_to(x0 + radius, y1);
                .curve_to(x0, y1, x0, y1, x0, y1- radius);
            }
        }

        .rgb(0.5, 0.5, 1);
        .fill(:preserve);
        .rgba(0.5, 0, 0, 0.5);
        .line_width = 10.0;
        .stroke;
    };
    .write_png("curve-rectangle.png");
}

