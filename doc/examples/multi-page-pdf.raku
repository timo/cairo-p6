use v6;
use Cairo;

given Cairo::Surface::PDF.create("multi-page-pdf.pdf", 256, 256) -> $s {
    given Cairo::Context.new($s) {
        # Tag for accessibility
        .tag: "Document", {
            for 1..2 -> $page {
                .set_font_size(10);
                 .tag: "Figure", {
                     .save;
                    .rgb(0, 0.7, 0.9);
                    .rectangle(10, 10, 50, 50);
                    .fill :preserve;
                    .rgb(1, 1, 1);
                    .stroke;
                    .restore;
                 };
                 .tag: "P", {
                     .select_font_face("courier", Cairo::FONT_SLANT_ITALIC, Cairo::FONT_WEIGHT_BOLD);
                     .move_to(10, 10);
                     .show_text("Page $page/2");
                 }
                 $s.show_page;
            }
            $s.finish;
        }
    }
}

