# This example requires the Font::FreeType module
use Cairo;
use Font::FreeType:ver<0.1.9+>;
use Font::FreeType::Face;
use Font::FreeType::Native;

my Font::FreeType $freetype .= new;

sub MAIN(
    :$font-file = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    :$png = 'freetype.png',
) {
    my Font::FreeType::Face $face = $freetype.face($font-file);
    # get the underlying FreeType Face native C-struct
    my FT_Face $face-struct = $face.native;
    my Cairo::Font $font .= create(
        $face-struct, :free-type,
    );

    freetype-demo($font, $png);

    $font.destroy;
}

sub freetype-demo(Cairo::Font:D $font, Str:D $png-file) {
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
        .write_png($png-file);

        .destroy;
    }
}

