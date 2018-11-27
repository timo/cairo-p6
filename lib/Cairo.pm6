unit module Cairo;

our $cairolib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $cairolib = 'libcairo-2';
    } else {
        $cairolib = ('cairo', v2);
    }
}

use NativeCall;

our enum cairo_status_t <
    STATUS_SUCCESS

    STATUS_NO_MEMORY
    STATUS_INVALID_RESTORE
    STATUS_INVALID_POP_GROUP
    STATUS_NO_CURRENT_POINT
    STATUS_INVALID_MATRIX
    STATUS_INVALID_STATUS
    STATUS_NULL_POINTER
    STATUS_INVALID_STRING
    STATUS_INVALID_PATH_DATA
    STATUS_READ_ERROR
    STATUS_WRITE_ERROR
    STATUS_SURFACE_FINISHED
    STATUS_SURFACE_TYPE_MISMATCH
    STATUS_PATTERN_TYPE_MISMATCH
    STATUS_INVALID_CONTENT
    STATUS_INVALID_FORMAT
    STATUS_INVALID_VISUAL
    STATUS_FILE_NOT_FOUND
    STATUS_INVALID_DASH
    STATUS_INVALID_DSC_COMMENT
    STATUS_INVALID_INDEX
    STATUS_CLIP_NOT_REPRESENTABLE
    STATUS_TEMP_FILE_ERROR
    STATUS_INVALID_STRIDE
    STATUS_FONT_TYPE_MISMATCH
    STATUS_USER_FONT_IMMUTABLE
    STATUS_USER_FONT_ERROR
    STATUS_NEGATIVE_COUNT
    STATUS_INVALID_CLUSTERS
    STATUS_INVALID_SLANT
    STATUS_INVALID_WEIGHT
    STATUS_INVALID_SIZE
    STATUS_USER_FONT_NOT_IMPLEMENTED
    STATUS_DEVICE_TYPE_MISMATCH
    STATUS_DEVICE_ERROR
    STATUS_INVALID_MESH_CONSTRUCTION
    STATUS_DEVICE_FINISHED

    STATUS_LAST_STATUS
>;

my class StreamClosure is repr('CStruct') is rw {

    sub memcpy(Pointer[uint8] $dest, Pointer[uint8] $src, size_t $n)
        is native
        {*}

    has CArray[uint8] $!buf;
    has size_t $.buf-len;
    has size_t $.n-read;
    has size_t $.size;
    method TWEAK(CArray :$buf!) { $!buf := $buf }
    method buf-pointer(--> Pointer[uint8]) {
        nativecast(Pointer[uint8], $!buf);
    }
    method read-pointer(--> Pointer) {
        Pointer[uint8].new: +$.buf-pointer + $!n-read;
    }
    method write-pointer(--> Pointer) {
        Pointer[uint8].new: +$.buf-pointer + $!buf-len;
    }
    our method read(Pointer $out, uint32 $len --> int32) {
        return STATUS_READ_ERROR
            if $len > self.buf-len - self.n-read;

        memcpy($out, self.read-pointer, $len);
        self.n-read += $len;
        return STATUS_SUCCESS;
    }
    our method write(Pointer $in, uint32 $len --> int32) {
        return STATUS_WRITE_ERROR
            if $len > self.size - self.buf-len;
        memcpy(self.write-pointer, $in, $len); 
        self.buf-len += $len;
        return STATUS_SUCCESS;
    }
 }

our class cairo_surface_t is repr('CPointer') {

    method write_to_png(Str $filename)
        returns int32
        is native($cairolib)
        is symbol('cairo_surface_write_to_png')
        {*}

    method write_to_png_stream(
            &write-func (StreamClosure, Pointer[uint8], uint32 --> int32),
            StreamClosure)
        returns int32
        is native($cairolib)
        is symbol('cairo_surface_write_to_png_stream')
        {*}

    method reference
        returns cairo_surface_t
        is native($cairolib)
        is symbol('cairo_surface_reference')
        {*}

    method show_page
        is native($cairolib)
        is symbol('cairo_surface_show_page')
        {*}

    method flush
        is native($cairolib)
        is symbol('cairo_surface_flush')
        {*}

    method finish
        is native($cairolib)
        is symbol('cairo_surface_finish')
        {*}

    method destroy
        is native($cairolib)
        is symbol('cairo_surface_destroy')
        {*}

    method get_image_data
        returns OpaquePointer
        is native($cairolib)
        is symbol('cairo_image_surface_get_data')
        {*}
    method get_image_stride
        returns int32
        is native($cairolib)
        is symbol('cairo_image_surface_get_stride')
        {*}
    method get_image_width
        returns int32
        is native($cairolib)
        is symbol('cairo_image_surface_get_width')
        {*}
    method get_image_height
        returns int32
        is native($cairolib)
        is symbol('cairo_image_surface_get_height')
        {*}

}

our class cairo_rectangle_t is repr('CPointer') { }

our class cairo_path_t is repr('CPointer') { }

our class cairo_text_extents_t is repr('CStruct') {
    has num64 $.x_bearing;
    has num64 $.y_bearing;
    has num64 $.width;
    has num64 $.height;
    has num64 $.x_advance;
    has num64 $.y_advance;
}

our class cairo_font_extents_t is repr('CStruct') {
    has num64 $.ascent;
    has num64 $.descent;
    has num64 $.height;
    has num64 $.max_x_advance;
    has num64 $.max_y_advance;
}

our class cairo_font_face_t is repr('CPointer') {
   method destroy
        is native($cairolib)
        is symbol('cairo_font_face_destroy')
        {*}
}

our class cairo_matrix_t is repr('CStruct') {
    has num64 $.xx; has num64 $.yx;
    has num64 $.xy; has num64 $.yy;
    has num64 $.x0; has num64 $.y0;

    method init(num64 $xx, num64 $yx, num64 $xy, num64 $yy, num64 $x0, num64 $y0)
        is native($cairolib)
        is symbol('cairo_matrix_init')
        {*}

    method scale(num64 $sx, num64 $sy)
        is native($cairolib)
        is symbol('cairo_matrix_scale')
        {*}

    method translate(num64 $tx, num64 $ty)
        is native($cairolib)
        is symbol('cairo_matrix_translate')
        {*}

    method rotate(cairo_matrix_t $b)
        is native($cairolib)
        is symbol('cairo_matrix_rotate')
        {*}

    method invert
        is native($cairolib)
        is symbol('cairo_matrix_invert')
        {*}

    method multiply(cairo_matrix_t $a, cairo_matrix_t $b)
        is native($cairolib)
        is symbol('cairo_matrix_multiply')
        {*}

}

our class cairo_pattern_t is repr('CPointer') {

    method destroy
        is native($cairolib)
        is symbol('cairo_pattern_destroy')
        {*}

    method get_extend
        returns int32
        is native($cairolib)
        is symbol('cairo_pattern_get_extend')
        {*}

    method set_extend(uint32 $extend)
        is native($cairolib)
        is symbol('cairo_pattern_set_extend')
        {*}

    method set_matrix(cairo_matrix_t $matrix)
        is native($cairolib)
        is symbol('cairo_pattern_set_matrix')
        {*}

    method get_matrix(cairo_matrix_t $matrix)
        is native($cairolib)
        is symbol('cairo_pattern_get_matrix')
        {*}

    method add_color_stop_rgb(num64 $offset, num64 $r, num64 $g, num64 $b)
        returns int32
        is native($cairolib)
        is symbol('cairo_pattern_add_color_stop_rgb')
        {*}

    method add_color_stop_rgba(num64 $offset, num64 $r, num64 $g, num64 $b, num64 $a)
        returns int32
        is native($cairolib)
        is symbol('cairo_pattern_add_color_stop_rgba')
        {*}

}

our class cairo_t is repr('CPointer') {

    method destroy
        is native($cairolib)
        is symbol('cairo_destroy')
        {*}

    method sub_path
        returns cairo_path_t
        is native($cairolib)
        is symbol('cairo_new_sub_path')
        {*}

    method copy_path
        returns cairo_path_t
        is native($cairolib)
        is symbol('cairo_copy_path')
        {*}

    method copy_path_flat
        returns cairo_path_t
        is native($cairolib)
        is symbol('cairo_copy_path_flat')
        {*}

    method append_path(cairo_path_t $path)
        returns cairo_path_t
        is native($cairolib)
        is symbol('cairo_append_path')
        {*}


    method push_group
        is native($cairolib)
        is symbol('cairo_push_group')
        {*}

    method pop_group
        returns cairo_pattern_t
        is native($cairolib)
        is symbol('cairo_pop_group')
        {*}

    method pop_group_to_source
        is native($cairolib)
        is symbol('cairo_pop_group_to_source')
        {*}


    method line_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_line_to')
        {*}

    method move_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_move_to')
        {*}

    method rel_line_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_rel_line_to')
        {*}

    method rel_move_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_rel_move_to')
        {*}

    method curve_to(num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3)
        is native($cairolib)
        is symbol('cairo_curve_to')
        {*}

    method arc(num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2)
        is native($cairolib)
        is symbol('cairo_arc')
        {*}
    method arc_negative(num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2)
        is native($cairolib)
        is symbol('cairo_arc_negative')
        {*}

    method close_path
        is native($cairolib)
        is symbol('cairo_close_path')
        {*}

    method new_path
        is native($cairolib)
        is symbol('cairo_new_path')
        {*}

    method rectangle(num64 $x, num64 $y, num64 $w, num64 $h)
        is native($cairolib)
        is symbol('cairo_rectangle')
        {*}


    method set_source_rgb(num64 $r, num64 $g, num64 $b)
        is native($cairolib)
        is symbol('cairo_set_source_rgb')
        {*}

    method set_source_rgba(num64 $r, num64 $g, num64 $b, num64 $a)
        is native($cairolib)
        is symbol('cairo_set_source_rgba')
        {*}

    method set_source(cairo_pattern_t $pat)
        is native($cairolib)
        is symbol('cairo_set_source')
        {*}

    method set_line_cap(int32 $cap)
        is native($cairolib)
        is symbol('cairo_set_line_cap')
        {*}

    method get_line_cap
        returns int32
        is native($cairolib)
        is symbol('cairo_get_line_cap')
        {*}

    method set_line_join(int32 $join)
        is native($cairolib)
        is symbol('cairo_set_line_join')
        {*}

    method get_line_join
        returns int32
        is native($cairolib)
        is symbol('cairo_get_line_join')
        {*}

    method set_fill_rule(int32 $cap)
        is native($cairolib)
        is symbol('cairo_set_fill_rule')
        {*}

    method get_fill_rule
        returns int32
        is native($cairolib)
        is symbol('cairo_get_fill_rule')
        {*}

    method set_line_width(num64 $width)
        is native($cairolib)
        is symbol('cairo_set_line_width')
        {*}
    method get_line_width
        returns num64
        is native($cairolib)
        is symbol('cairo_get_line_width')
        {*}

    method set_dash(CArray[num64] $dashes, int32 $len, num64 $offset)
        is native($cairolib)
        is symbol('cairo_set_dash')
        {*}

    method get_operator
        returns int32
        is native($cairolib)
        is symbol('cairo_get_operator')
        {*}
    method set_operator(int32 $op)
        is native($cairolib)
        is symbol('cairo_set_operator')
        {*}

    method get_antialias
        returns int32
        is native($cairolib)
        is symbol('cairo_get_antialias')
        {*}
    method set_antialias(int32 $op)
        is native($cairolib)
        is symbol('cairo_set_antialias')
        {*}

    method set_source_surface(cairo_surface_t $surface, num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_set_source_surface')
        {*}

    method mask(cairo_pattern_t $pattern)
        is native($cairolib)
        is symbol('cairo_mask')
        {*}
    method mask_surface(cairo_surface_t $surface, num64 $sx, num64 $sy)
        is native($cairolib)
        is symbol('cairo_mask_surface')
        {*}

    method clip
        is native($cairolib)
        is symbol('cairo_clip')
        {*}
    method clip_preserve
        is native($cairolib)
        is symbol('cairo_clip_preserve')
        {*}

    method fill
        is native($cairolib)
        is symbol('cairo_fill')
        {*}

    method stroke
        is native($cairolib)
        is symbol('cairo_stroke')
        {*}

    method fill_preserve
        is native($cairolib)
        is symbol('cairo_fill_preserve')
        {*}

    method stroke_preserve
        is native($cairolib)
        is symbol('cairo_stroke_preserve')
        {*}

    method paint
        is native($cairolib)
        is symbol('cairo_paint')
        {*}
    method paint_with_alpha(num64 $alpha)
        is native($cairolib)
        is symbol('cairo_paint_with_alpha')
        {*}

    method translate(num64 $tx, num64 $ty)
        is native($cairolib)
        is symbol('cairo_translate')
        {*}
    method scale(num64 $sx, num64 $sy)
        is native($cairolib)
        is symbol('cairo_scale')
        {*}
    method rotate(num64 $angle)
        is native($cairolib)
        is symbol('cairo_rotate')
        {*}
    method transform(cairo_matrix_t $matrix)
        is native($cairolib)
        is symbol('cairo_transform')
        {*}
    method identity_matrix
        is native($cairolib)
        is symbol('cairo_identity_matrix')
        {*}
    method set_matrix(cairo_matrix_t $matrix)
        is native($cairolib)
        is symbol('cairo_set_matrix')
        {*}
    method get_matrix(cairo_matrix_t $matrix)
        is native($cairolib)
        is symbol('cairo_get_matrix')
        {*}

    method save
        is native($cairolib)
        is symbol('cairo_save')
        {*}
    method restore
        is native($cairolib)
        is symbol('cairo_restore')
        {*}

    method status
        returns int32
        is native($cairolib)
        is symbol('cairo_status')
        {*}


    method select_font_face(Str $family, int32 $slant, int32 $weight)
        is native($cairolib)
        is symbol('cairo_select_font_face')
        {*}

    method set_font_face(cairo_font_face_t $font)
        is native($cairolib)
        is symbol('cairo_set_font_face')
        {*}

    method set_font_size(num64 $size)
        is native($cairolib)
        is symbol('cairo_set_font_size')
        {*}

    method show_text(Str $utf8)
        is native($cairolib)
        is symbol('cairo_show_text')
        {*}

    method text_path(Str $utf8)
        is native($cairolib)
        is symbol('cairo_text_path')
        {*}

    method text_extents(Str $utf8, cairo_text_extents_t $extents)
        is native($cairolib)
        is symbol('cairo_text_extents')
        {*}

    method font_extents(cairo_font_extents_t $extents)
        is native($cairolib)
        is symbol('cairo_font_extents')
        {*}

}

our class Matrix  { ... }
our class Surface { ... }
our class Image   { ... }
our class Pattern { ... }
our class Context { ... }
our class Font    { ... }

our enum Format (
     FORMAT_INVALID => -1,
    "FORMAT_ARGB32"   ,
    "FORMAT_RGB24"    ,
    "FORMAT_A8"       ,
    "FORMAT_A1"       ,
    "FORMAT_RGB16_565",
    "FORMAT_RGB30"    ,
);

our enum Operator <
    OPERATOR_CLEAR

    OPERATOR_SOURCE
    OPERATOR_OVER
    OPERATOR_IN
    OPERATOR_OUT
    OPERATOR_ATOP

    OPERATOR_DEST
    OPERATOR_DEST_OVER
    OPERATOR_DEST_IN
    OPERATOR_DEST_OUT
    OPERATOR_DEST_ATOP

    OPERATOR_XOR
    OPERATOR_ADD
    OPERATOR_SATURATE

    OPERATOR_MULTIPLY
    OPERATOR_SCREEN
    OPERATOR_OVERLAY
    OPERATOR_DARKEN
    OPERATOR_LIGHTEN
    OPERATOR_COLOR_DODGE
    OPERATOR_COLOR_BURN
    OPERATOR_HARD_LIGHT
    OPERATOR_SOFT_LIGHT
    OPERATOR_DIFFERENCE
    OPERATOR_EXCLUSION
    OPERATOR_HSL_HUE
    OPERATOR_HSL_SATURATION
    OPERATOR_HSL_COLOR
    OPERATOR_HSL_LUMINOSITY
>;

our enum LineCap <
    LINE_CAP_BUTT
    LINE_CAP_ROUND
    LINE_CAP_SQUARE
>;

our enum LineJoin <
    LINE_JOIN_MITER
    LINE_JOIN_ROUND
    LINE_JOIN_BEVEL
>;

our enum Content (
    CONTENT_COLOR => 0x1000,
    CONTENT_ALPHA => 0x2000,
    CONTENT_COLOR_ALPHA => 0x3000,
);

our enum Antialias <
    ANTIALIAS_DEFAULT
    ANTIALIAS_NONE
    ANTIALIAS_GRAY
    ANTIALIAS_SUBPIXEL
    ANTIALIAS_FAST
    ANTIALIAS_GOOD
    ANTIALIAS_BEST
>;

our enum FontWeight <
    FONT_WEIGHT_NORMAL
    FONT_WEIGHT_BOLD
>;

our enum FontSlant <
    FONT_SLANT_NORMAL
    FONT_SLANT_ITALIC
    FONT_SLANT_OBLIQUE
>;

our enum Extend <
    EXTEND_NONE
    EXTEND_REPEAT
    EXTEND_REFLECT
    CAIRO_EXTEND_PAD
>;

our enum FillRule <
    FILL_RULE_WINDING
    FILL_RULE_EVEN_ODD
>;

class Matrix {
    has cairo_matrix_t $.matrix handles <
        xx yx xy yy x0 y0
    > .= new: :xx(1e0), :yy(1e0);

    multi method init(Num(Cool) :$xx = 1e0, Num(Cool) :$yx = 0e0, Num(Cool) :$xy = 0e0, Num(Cool) :$yy = 1e0, Num(Cool) :$x0 = 0e0, Num(Cool) :$y0 = 0e0) {
        $!matrix.init( $xx, $yx, $xy, $yy, $x0, $y0 );
        self;
    }

    multi method init(Num(Cool) $xx, Num(Cool) $yx = 0e0,
                      Num(Cool) $xy = 0e0, Num(Cool) $yy = 1e0,
                      Num(Cool) $x0 = 0e0, Num(Cool) $y0 = 0e0) {
        $!matrix.init( $xx, $yx, $xy, $yy, $x0, $y0 );
        self;
    }

    method scale(Num(Cool) $sx, Num(Cool) $sy) {
        $!matrix.scale($sx, $sy);
        self;
    }

    method translate(Num(Cool) $tx, Num(Cool) $ty) {
        $!matrix.translate($tx, $ty);
        self;
    }

    method rotate(Num(Cool) $rad) {
        $!matrix.rotate($rad);
        self;
    }

    method invert {
        $!matrix.invert;
        self;
    }

    method multiply(Matrix $b) {
        my cairo_matrix_t $a-matrix = $!matrix;
        $!matrix = cairo_matrix_t.new;
        $!matrix.multiply($a-matrix, $b.matrix);
        self;
    }

}

class Surface {
    has cairo_surface_t $.surface handles <reference destroy flush finish show_page>;

    method write_png(Str $filename) {
        my $result = $!surface.write_to_png($filename);
        fail cairo_status_t($result) if $result != STATUS_SUCCESS;
        cairo_status_t($result);
    }

    method Blob(UInt :$size = 64_000 --> Blob) {
         my $buf = CArray[uint8].new;
         $buf[$size] = 0;
         my $closure = StreamClosure.new: :$buf, :buf-len(0), :n-read(0), :$size;
         $!surface.write_to_png_stream(&StreamClosure::write, $closure);
         return Blob[uint8].new: $buf[0 ..^ $closure.buf-len];
    }

    method record(&things) {
        my $ctx = Context.new(self);
        &things($ctx);
        $ctx.destroy();
        return self;
    }

}

class Surface::PDF is Surface {
    sub cairo_pdf_surface_create(str $filename, num64 $width, num64 $height)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    has Num $.width;
    has Num $.height;

    multi method create(str $filename, num64 $width, num64 $height) {
        return self.new(
            surface => cairo_pdf_surface_create($filename, $width, $height),
            :$width, :$height,
            )
    }
    multi method create(Str(Cool) $filename, Num(Cool) $width, Num(Cool) $height) {
        return self.new(
            surface => cairo_pdf_surface_create($filename, $width, $height),
            :$width, :$height,
            )
    }

}

class Surface::SVG is Surface {
    sub cairo_svg_surface_create(str $filename, num64 $width, num64 $height)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    has Num $.width;
    has Num $.height;

    multi method create(str $filename, num64 $width, num64 $height) {
        return self.new(
            surface => cairo_svg_surface_create($filename, $width, $height),
            :$width, :$height,
            )
    }
    multi method create(Str(Cool) $filename, Num(Cool) $width, Num(Cool) $height) {
        return self.new(
            surface => cairo_svg_surface_create($filename, $width, $height),
            :$width, :$height,
            )
    }

}

class RecordingSurface {
    sub cairo_recording_surface_create(int32 $content, cairo_rectangle_t $extents)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    method new(Content $content = CONTENT_COLOR_ALPHA) {
        my cairo_surface_t $surface = cairo_recording_surface_create($content.Int, OpaquePointer);
        my RecordingSurface $rsurf = self.bless: :$surface;
        $rsurf.reference;
        $rsurf;
    }

    method record(&things, Content :$content = CONTENT_COLOR_ALPHA) {
        my Context $ctx .= new(my $surface = self.new($content));
        &things($ctx);
        $ctx.destroy();
        return $surface;
    }
}

class Image is Surface {
    sub cairo_image_surface_create(int32 $format, int32 $width, int32 $height)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_image_surface_create_for_data(Blob[uint8] $data, int32 $format, int32 $width, int32 $height, int32 $stride)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_image_surface_create_from_png(Str $filename)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_image_surface_create_from_png_stream(
            &read-func (StreamClosure, Pointer[uint8], uint32 --> int32),
            StreamClosure)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_format_stride_for_width(int32 $format, int32 $width)
        returns int32
        is native($cairolib)
        {*}

    multi method create(Format $format, Cool $width, Cool $height) {
        return self.new(surface => cairo_image_surface_create($format.Int, $width.Int, $height.Int));
    }

    multi method create(Format $format, Cool $width, Cool $height, Blob[uint8] $data, Cool $stride?) {
        if $stride eqv False {
            $stride = $width.Int;
        } elsif $stride eqv True {
            $stride = cairo_format_stride_for_width($format.Int, $width.Int);
        }
        return self.new(surface => cairo_image_surface_create_for_data($data, $format.Int, $width.Int, $height.Int, $stride));
    }

    multi method create(Blob[uint8] $data, Int(Cool) $buf-len = $data.elems) {

        my $buf = CArray[uint8].new: $data;
        my $closure = StreamClosure.new: :$buf, :$buf-len, :n-read(0);
        return self.new(surface => cairo_image_surface_create_from_png_stream(&StreamClosure::read, $closure));
    }

    multi method open(str $filename) {
        return self.new(surface => cairo_image_surface_create_from_png($filename));
    }
    multi method open(Str(Cool) $filename) {
        return self.new(surface => cairo_image_surface_create_from_png($filename));
    }

    method record(&things, Cool $width?, Cool $height?, Format $format = FORMAT_ARGB32) {
        if defined $width and defined $height {
            my $surface = self.create($format, $width, $height);
            my $ctx = Context.new($surface);
            &things($ctx);
            return $surface;
        } else {
            die "recording surfaces are currently NYI. please specify a width and height for your Cairo::Image.";
        }
    }

    method data()   { $.surface.get_image_data }
    method stride() { $.surface.get_image_stride }
    method width()  { $.surface.get_image_width }
    method height() { $.surface.get_image_height }
}

class Pattern::Solid { ... }
class Pattern::Surface { ... }
class Pattern::Gradient { ... }
class Pattern::Gradient::Linear { ... }
class Pattern::Gradient::Radial { ... }

class Pattern {

    has cairo_pattern_t $.pattern handles <destroy>;

    multi method new(cairo_pattern_t $pattern) {
        self.bless(:$pattern)
    }

    method extend() is rw {
        Proxy.new:
            FETCH => { Extend($!pattern.get_extend) },
            STORE => -> \c, \value { $!pattern.set_extend(value.Int) }
    }

    method matrix() is rw {
        Proxy.new:
            FETCH => {
                my cairo_matrix_t $matrix .= new;
                $!pattern.get_matrix($matrix);
                Cairo::Matrix.new: :$matrix;
            },
            STORE => -> \c, Cairo::Matrix \matrix { $!pattern.set_matrix(matrix.matrix) }
    }

}

class Pattern::Solid is Pattern {

    sub cairo_pattern_create_rgb(num64 $r, num64 $g, num64 $b)
        returns cairo_pattern_t
        is native($cairolib)
        {*}

    sub cairo_pattern_create_rgba(num64 $r, num64 $g, num64 $b, num64 $a)
        returns cairo_pattern_t
        is native($cairolib)
        {*}

    multi method create(Num(Cool) $r, Num(Cool) $g, Num(Cool) $b) {
        self.new: cairo_pattern_create_rgb($r, $g, $b);
    }

    multi method create(Num(Cool) $r, Num(Cool) $g, Num(Cool) $b, Num(Cool) $a) {
        self.new: cairo_pattern_create_rgba($r, $g, $b, $a);
    }

}

class Pattern::Surface is Pattern {
    sub cairo_pattern_create_for_surface(cairo_surface_t $surface)
        returns cairo_pattern_t
        is native($cairolib)
        {*}

    method create(cairo_surface_t $surface) {
        self.new: cairo_pattern_create_for_surface($surface);
    }

}

class Pattern::Gradient is Pattern {

    method add_color_stop_rgb(Num(Cool) $offset, Num(Cool) $r, Num(Cool) $g, Num(Cool) $b) {
        $.pattern.add_color_stop_rgb($offset, $r, $g, $b);
    }

    method add_color_stop_rgba(Num(Cool) $offset, Num(Cool) $r, Num(Cool) $g, Num(Cool) $b, Num(Cool) $a) {
        $.pattern.add_color_stop_rgba($offset, $r, $g, $b, $a);
    }

}

class Pattern::Gradient::Linear is Pattern::Gradient {

    sub cairo_pattern_create_linear(num64 $x0, num64 $y0, num64 $x1, num64 $y1)
        returns cairo_pattern_t
        is native($cairolib)
        {*}

    method create(Num(Cool) $x0, Num(Cool) $y0, Num(Cool) $x1, Num(Cool) $y1) {
        self.new: cairo_pattern_create_linear($x0, $y0, $x1, $y1);
    }

}

class Pattern::Gradient::Radial is Pattern::Gradient {
    sub cairo_pattern_create_radial(num64 $cx0, num64 $cy0, num64 $r0, num64 $cx1, num64 $cy1, num64 $r1)
        returns cairo_pattern_t
        is native($cairolib)
        {*}

    method create(Num(Cool) $cx0, Num(Cool) $cy0, Num(Cool) $r0,
                  Num(Cool) $cx1, Num(Cool) $cy1, Num(Cool) $r1) {
        self.new: cairo_pattern_create_radial($cx0, $cy0, $r0, $cx1, $cy1, $r1);
    }

}

class Context {
    sub cairo_create(cairo_surface_t $surface)
        returns cairo_t
        is native($cairolib)
        {*}

    has cairo_t $!context handles <
        status destroy push_group pop_group_to_source sub_path append_path
        save restore paint close_path new_path identity_matrix
    >;

    multi method new(cairo_t $context) {
        self.bless(:$context);
    }

    multi method new(Surface $surface) {
        my $context = cairo_create($surface.surface);
        self.bless(:$context);
    }

    submethod BUILD(:$!context) { }

    method pop_group() returns Pattern {
        Pattern.new($!context.pop_group);
    }

    multi method copy_path() {
        $!context.copy_path
    }
    multi method copy_path(:$flat! where .so) {
        $!context.copy_path_flat
    }

    method memoize_path($storage is rw, &creator, :$flat?) {
        if defined $storage {
            self.append_path($storage);
        } else {
            &creator();
            $storage = self.copy_path(:$flat);
        }
    }

    multi method rgb(Num(Cool) $r, Num(Cool) $g, Num(Cool) $b) {
        $!context.set_source_rgb($r, $g, $b);
    }
    multi method rgb(num $r, num $g, num $b) {
        $!context.set_source_rgb($r, $g, $b);
    }

    multi method rgba(Num(Cool) $r, Num(Cool) $g, Num(Cool) $b, Num(Cool) $a) {
        $!context.set_source_rgba($r, $g, $b, $a);
    }
    multi method rgb(num $r, num $g, num $b, num $a) {
        $!context.set_source_rgba($r, $g, $b, $a);
    }

    method pattern(Pattern $pat) {
        $!context.set_source($pat.pattern);
    }

    method set_source_surface(Surface $surface, Num(Cool) $x = 0, Num(Cool) $y = 0) {
        $!context.set_source_surface($surface.surface, $x, $y)
    }

    multi method mask(Pattern $pat, Num(Cool) $sx = 0, Num(Cool) $sy = 0) {
        $!context.mask($pat.pattern, $sx, $sy)
    }
    multi method mask(Pattern $pat, num $sx = 0e0, num $sy = 0e0) {
        $!context.mask($pat.pattern, $sx, $sy)
    }
    multi method mask(Surface $surface, Num(Cool) $sx = 0, Num(Cool) $sy = 0) {
        $!context.mask_surface($surface.surface, $sx, $sy)
    }
    multi method mask(Surface $surface, num $sx = 0e0, num $sy = 0e0) {
        $!context.mask_surface($surface.surface, $sx, $sy)
    }

    multi method fill {
        $!context.fill
    }
    multi method stroke {
        $!context.stroke
    }
    multi method fill(:$preserve! where .so) {
        $!context.fill_preserve
    }
    multi method stroke(:$preserve! where .so) {
        $!context.stroke_preserve
    }
    multi method clip {
        $!context.clip
    }
    multi method clip(:$preserve! where .so) {
        $!context.clip_preserve
    }

    multi method paint_with_alpha( num64 $alpha) {
        $!context.paint_with_alpha($alpha)
    }
    multi method paint_with_alpha( Num(Cool) $alpha) {
        $!context.paint_with_alpha($alpha)
    }

    multi method move_to(Num(Cool) $x, Num(Cool) $y) {
        $!context.move_to($x, $y);
    }
    multi method line_to(Num(Cool) $x, Num(Cool) $y) {
        $!context.line_to($x, $y);
    }

    multi method move_to(Num(Cool) $x, Num(Cool) $y, :$relative! where .so) {
        $!context.rel_move_to($x, $y);
    }
    multi method line_to(Num(Cool) $x, Num(Cool) $y, :$relative! where .so) {
        $!context.rel_line_to($x, $y);
    }

    multi method curve_to(Num(Cool) $x1, Num(Cool) $y1, Num(Cool) $x2, Num(Cool) $y2, Num(Cool) $x3, Num(Cool) $y3) {
        $!context.curve_to($x1, $y1, $x2, $y2, $x3, $y3);
    }

    multi method arc(Num(Cool) $xc, Num(Cool) $yc, Num(Cool) $radius, Num(Cool) $angle1, Num(Cool) $angle2, :$negative! where .so) {
        $!context.arc_negative($xc, $yc, $radius, $angle1, $angle2);
    }
    multi method arc(num $xc, num $yc, num $radius, num $angle1, num $angle2, :$negative! where .so) {
        $!context.arc_negative($xc, $yc, $radius, $angle1, $angle2);
    }

    multi method arc(Num(Cool) $xc, Num(Cool) $yc, Num(Cool) $radius, Num(Cool) $angle1, Num(Cool) $angle2) {
        $!context.arc($xc, $yc, $radius, $angle1, $angle2);
    }
    multi method arc(num $xc, num $yc, num $radius, num $angle1, num $angle2) {
        $!context.arc($xc, $yc, $radius, $angle1, $angle2);
    }

    multi method rectangle(Num(Cool) $x, Num(Cool) $y, Num(Cool) $w, Num(Cool) $h) {
        $!context.rectangle($x, $y, $w, $h);
    }
    multi method rectangle(num $x, num $y, num $w, num $h) {
        $!context.rectangle($x, $y, $w, $h);
    }

    multi method translate(num $tx, num $ty) {
        $!context.translate($tx, $ty)
    }
    multi method translate(Num(Cool) $tx, Num(Cool) $ty) {
        $!context.translate($tx, $ty)
    }

    multi method scale(num $sx, num $sy) {
        $!context.scale($sx, $sy)
    }
    multi method scale(Num(Cool) $sx, Num(Cool) $sy) {
        $!context.scale($sx, $sy)
    }

    multi method rotate(num $angle) {
        $!context.rotate($angle)
    }
    multi method rotate(Num(Cool) $angle) {
        $!context.rotate($angle)
    }

    method transform(Matrix $matrix) {
        $!context.transform($matrix.matrix)
    }

    multi method select_font_face(str $family, int32 $slant, int32 $weight) {
        $!context.select_font_face($family, $slant, $weight);
    }
    multi method select_font_face(Str(Cool) $family, Int(Cool) $slant, Int(Cool) $weight) {
        $!context.select_font_face($family, $slant, $weight);
    }
    method set_font_face(Cairo::Font $font) {
        $!context.set_font_face($font.face);
    }

    multi method set_font_size(num $size) {
        $!context.set_font_size($size);
    }
    multi method set_font_size(Num(Cool) $size) {
        $!context.set_font_size($size);
    }

    multi method show_text(str $text) {
        $!context.show_text($text);
    }
    multi method show_text(Str(Cool) $text) {
        $!context.show_text($text);
    }

    multi method text_path(str $text) {
        $!context.text_path($text);
    }
    multi method text_path(Str(Cool) $text) {
        $!context.text_path($text);
    }

    multi method text_extents(str $text --> cairo_text_extents_t) {
        my cairo_text_extents_t $extents .= new;
        $!context.text_extents($text, $extents);
        $extents;
    }
    multi method text_extents(Str(Cool) $text --> cairo_text_extents_t) {
        my cairo_text_extents_t $extents .= new;
        $!context.text_extents($text, $extents);
        $extents;
    }

    method font_extents {
        my cairo_font_extents_t $extents .= new;
        $!context.font_extents($extents);
        $extents;
    }

    multi method set_dash(CArray[num64] $dashes, int32 $len, num64 $offset) {
        $!context.set_dash($dashes, $len, $offset);
    }
    multi method set_dash(List $dashes, Int(Cool) $len, Num(Cool) $offset) {
        my $d = CArray[num64].new;
        $d[$_] = $dashes[$_].Num
            for 0 ..^ $len;
        $!context.set_dash($d, $len, $offset);
    }

    method line_cap() is rw {
        Proxy.new:
            FETCH => { LineCap($!context.get_line_cap) },
            STORE => -> \c, \value { $!context.set_line_cap(value.Int) }
    }

    method fill_rule() is rw {
        Proxy.new:
            FETCH => { LineCap($!context.get_fill_rule) },
            STORE => -> \c, \value { $!context.set_fill_rule(value.Int) }
    }

    method line_join() is rw {
        Proxy.new:
            FETCH => { LineJoin($!context.get_line_join) },
            STORE => -> \c, \value { $!context.set_line_join(value.Int) }
    }

    method operator() is rw {
        Proxy.new:
            FETCH => { Operator($!context.get_operator) },
            STORE => -> \c, \value { $!context.set_operator(value.Int) }
    }

    method antialias() is rw {
        Proxy.new:
            FETCH => { Antialias($!context.get_antialias) },
            STORE => -> \c, \value { $!context.set_antialias(value.Int) }
    }

    method line_width() is rw {
        Proxy.new:
            FETCH => { $!context.get_line_width},
            STORE => -> \c, \value { $!context.set_line_width(value.Num) }
    }

    method matrix() is rw {
        Proxy.new:
            FETCH => {
                my cairo_matrix_t $matrix .= new;
                $!context.get_matrix($matrix);
                Matrix.new: :$matrix;
            },
            STORE => -> \c, Matrix \matrix { $!context.set_matrix(matrix.matrix) }
    }

}

class Font {
    sub cairo_ft_font_face_create_for_ft_face(Pointer $ft-face, int32 $flags)
        returns cairo_font_face_t
        is native($cairolib)
        {*}

      has cairo_font_face_t $.face handles <destroy>;
      multi method create($font-face, :$free-type! where .so, Int :$flags = 0) {
          return self.new(
                 face => cairo_ft_font_face_create_for_ft_face( nativecast(Pointer, $font-face),
                                                                $flags )
                 )
      }
}
