use v6;
use Cairo;

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {
    given Cairo::Context.new($_) {

        .line_width = 6;

        .rectangle(12, 12, 232, 70);
        .sub_path; .arc(64, 64, 40, 0, 2*pi);
        .sub_path; .arc(192, 64, 40, 0, -2*pi, :negative);

        .fill_rule = Cairo::FILL_RULE_EVEN_ODD;
        .rgb(0, 0.7, 0); .fill(:preserve);
        .rgb(0, 0, 0); .stroke;

        .translate(0, 128);
        .rectangle(12, 12, 232, 70);
        .sub_path; .arc(64, 64, 40, 0, 2*pi);
        .sub_path; .arc(192, 64, 40, 0, -2*pi, :negative);

        .fill_rule = Cairo::FILL_RULE_WINDING;
        .rgb(0, 0, 0.9); .fill(:preserve);
        .rgb(0, 0, 0); .stroke;
    };
    .write_png("fill-style.png");
}

