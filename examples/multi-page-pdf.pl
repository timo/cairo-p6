use v6;
use Cairo;

given Cairo::Surface::PDF.create("multi-page-pdf.pdf", 256, 256) {
    for 1..2 -> $page {
        given Cairo::Context.new($_) {

            .select_font_face("courier", Cairo::FONT_SLANT_ITALIC, Cairo::FONT_WEIGHT_BOLD);
            .set_font_size(10);
            .save;
             do {
                .rgb(0, 0.7, 0.9);
                .rectangle(10, 10, 50, 50);
                .fill :preserve; .rgb(1, 1, 1);
                .stroke;
            };
            .restore;
            .move_to(10, 10);
            .show_text("Page $page/2");
        }
        .show_page;

    };
    .finish;
}

