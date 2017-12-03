# This example requires the Font::FreeType module
use Cairo;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Native;

my Font::FreeType $freetype .= new;
my Font::FreeType::Face $face = $freetype.face('examples/fonts/DejaVuSans.ttf');
# get the underlying native struct
my FT_Face $ft-face = $face.struct;
# reference count it. to ensure it doesn't get destroyed
$ft-face.FT_Reference_Face;
my Cairo::Font $font .= create(
    $face.struct, :free-type,
);

given Cairo::Image.create(Cairo::FORMAT_ARGB32, 256, 256) {

        given Cairo::Context.new($_) {

        .set_font_size(90.0);
        .set_font_face($font);
        .move_to(10.0, 135.0);
        .show_text("Hello");

        .move_to(70.0, 165.0);
        .text_path("font");
        .rgb(0.5, 0.5, 1);
        .fill(:preserve);
        .rgb(0, 0, 0);
        .line_width = 2.56;
        .stroke;

        # draw helping lines
        .rgba(1, 0.2, 0.2, 0.6);
        .arc(10.0, 135.0, 5.12, 0, 2*pi);
        .close_path;
        .arc(70.0, 165.0, 5.12, 0, 2*pi);
        .fill;
    }
    .write_png("freetype.png");

    .destroy;
}

# just to demonstrate graceful tidy-up of Cairo and FreeType faces.
$font.destroy;
$font = Nil;
$ft-face.FT_Done_Face;
$ft-face = Nil;
