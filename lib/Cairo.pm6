module Cairo {

my $cairolib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $cairolib = 'libcairo-2';
    } else {
        $cairolib = ('cairo', v2);
    }
}

use NativeCall;

our class cairo_t is repr('CPointer') { }

our class cairo_surface_t is repr('CPointer') { }

our class cairo_pattern_t is repr('CPointer') { }

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

our class cairo_matrix_t is repr('CStruct') {
    has num64 $.xx; has num64 $.yx;
    has num64 $.xy; has num64 $.yy;
    has num64 $.x0; has num64 $.y0;

    sub cairo_matrix_init_identity(cairo_matrix_t $matrix)
        is native($cairolib)
        {*}

    sub cairo_matrix_init_scale(cairo_matrix_t $matrix, num64 $sx, num64 $sy)
        is native($cairolib)
        {*}

    multi method init(:$identity! where .so) {
        cairo_matrix_init_identity(self);
        return self;
    }

    multi method init(Num(Cool) $sx, Num(Cool) $sy, :$scale where .so) {
        cairo_matrix_init_scale(self, $sx, $sy);
        return self;
    }

}

our class Surface { ... }
our class Image { ... }
our class Pattern { ... }
our class Context { ... }

our enum Format (
     FORMAT_INVALID => -1,
    "FORMAT_ARGB32"   ,
    "FORMAT_RGB24"    ,
    "FORMAT_A8"       ,
    "FORMAT_A1"       ,
    "FORMAT_RGB16_565",
    "FORMAT_RGB30"    ,
);

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

sub cairo_format_stride_for_width(int32 $format, int32 $width)
    returns int32
    is native($cairolib)
    {*}

class Surface {
    has $.surface;

    sub cairo_surface_write_to_png(cairo_surface_t $surface, Str $filename)
        returns int32
        is native($cairolib)
        {*}

    sub cairo_surface_reference(cairo_surface_t $surface)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_surface_show_page(cairo_surface_t $surface)
        is native($cairolib)
        {*}

    sub cairo_surface_finish(cairo_surface_t $surface)
        is native($cairolib)
        {*}

    sub cairo_surface_destroy(cairo_surface_t $surface)
        is native($cairolib)
        {*}

    method write_png(Str $filename) {
        my $result = cairo_surface_write_to_png($!surface, $filename);
        fail cairo_status_t($result) if $result != STATUS_SUCCESS;
        cairo_status_t($result);
    }

    method record(&things) {
        my $ctx = Context.new(self);
        &things($ctx);
        $ctx.destroy();
        return self;
    }

    method show_page { cairo_surface_show_page($.surface) }
    method finish { cairo_surface_finish($.surface) }

    method reference() { cairo_surface_reference($!surface) }
    method destroy  () { cairo_surface_destroy($!surface) }
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

    class StreamClosure is repr('CStruct') is rw {
        has CArray[uint8] $!buf;
        has size_t $.buf-len;
        has size_t $.n-read;
        method TWEAK(CArray :$buf!) { $!buf := $buf }
        method buf-pointer(--> Pointer[uint8]) {
            nativecast(Pointer[uint8], $!buf);
        }
        method read-pointer(--> Pointer) {
            Pointer[uint8].new: +$.buf-pointer + $!n-read;
        }
        our sub read(StreamClosure $closure, Pointer $out, uint32 $len --> int32) {
            return STATUS_READ_ERROR
                if $len > $closure.buf-len - $closure.n-read;

            memcpy($out, $closure.read-pointer, $len);
            $closure.n-read += $len;
            return STATUS_SUCCESS;
        }
     }

    sub cairo_image_surface_create_from_png(Str $filename)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_image_surface_create_from_png_stream(&read-func (StreamClosure, Pointer[uint8], uint32 --> int32), StreamClosure)
        returns cairo_surface_t
        is native($cairolib)
        {*}

    sub cairo_image_surface_get_data(cairo_surface_t $surface)
        returns OpaquePointer
        is native($cairolib)
        {*}
    sub cairo_image_surface_get_stride(cairo_surface_t $surface)
        returns int32
        is native($cairolib)
        {*}
    sub cairo_image_surface_get_width(cairo_surface_t $surface)
        returns int32
        is native($cairolib)
        {*}
    sub cairo_image_surface_get_height(cairo_surface_t $surface)
        returns int32
        is native($cairolib)
        {*}
    sub memcpy(Pointer[uint8] $dest, Pointer[uint8] $src, size_t $n)
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

    method data()   { cairo_image_surface_get_data($.surface) }
    method stride() { cairo_image_surface_get_stride($.surface) }
    method width()  { cairo_image_surface_get_width($.surface) }
    method height() { cairo_image_surface_get_height($.surface) }
}

class Pattern::Solid { ... }
class Pattern::Surface { ... }
class Pattern::Gradient { ... }
class Pattern::Gradient::Linear { ... }
class Pattern::Gradient::Radial { ... }

class Pattern {

    sub cairo_pattern_destroy(cairo_pattern_t $pat)
        is native($cairolib)
        {*}

    sub cairo_pattern_get_extend(cairo_pattern_t $pat)
        returns int32
        is native($cairolib)
        {*}

    sub cairo_pattern_set_extend(cairo_pattern_t $pat, uint32 $extend)
        is native($cairolib)
        {*}

    sub cairo_pattern_set_matrix(cairo_pattern_t $ctx, cairo_matrix_t $matrix)
        is native($cairolib)
        {*}
    sub cairo_pattern_get_matrix(cairo_pattern_t $ctx, cairo_matrix_t $matrix)
        is native($cairolib)
        {*}

    has $.pattern;

    multi method new(cairo_pattern_t $pattern) {
        self.bless(:$pattern)
    }

    method extend() {
        Proxy.new:
            FETCH => { Extend(cairo_pattern_get_extend($!pattern)) },
            STORE => -> \c, \value { cairo_pattern_set_extend($!pattern, value.Int) }
    }

    method matrix() {
        Proxy.new:
            FETCH => {
                my cairo_matrix_t $matrix .= new;
                cairo_pattern_get_matrix($!pattern, $matrix);
                $matrix;
            },
            STORE => -> \c, cairo_matrix_t \matrix { cairo_pattern_set_matrix($!pattern, matrix) }
    }

    method destroy() {
        cairo_pattern_destroy($!pattern);
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

    sub cairo_pattern_add_color_stop_rgb(cairo_pattern_t $pat, num64 $offset, num64 $r, num64 $g, num64 $b)
        returns int32
        is native($cairolib)
        {*}

    sub cairo_pattern_add_color_stop_rgba(cairo_pattern_t $pat, num64 $offset, num64 $r, num64 $g, num64 $b, num64 $a)
        returns int32
        is native($cairolib)
        {*}

    method add_color_stop_rgb(Num(Cool) $offset, Num(Cool) $r, Num(Cool) $g, Num(Cool) $b) {
        cairo_pattern_add_color_stop_rgb($.pattern, $offset, $r, $g, $b);
    }

    method add_color_stop_rgba(Num(Cool) $offset, Num(Cool) $r, Num(Cool) $g, Num(Cool) $b, Num(Cool) $a) {
        cairo_pattern_add_color_stop_rgba($.pattern, $offset, $r, $g, $b, $a);
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

    sub cairo_destroy(cairo_t $ctx)
        is native($cairolib)
        {*}


    sub cairo_new_sub_path(cairo_t $ctx)
        returns cairo_path_t
        is native($cairolib)
        {*}

    sub cairo_copy_path(cairo_t $ctx)
        returns cairo_path_t
        is native($cairolib)
        {*}

    sub cairo_copy_path_flat(cairo_t $ctx)
        returns cairo_path_t
        is native($cairolib)
        {*}

    sub cairo_append_path(cairo_t $ctx, cairo_path_t $path)
        returns cairo_path_t
        is native($cairolib)
        {*}


    sub cairo_push_group(cairo_t $ctx)
        is native($cairolib)
        {*}

    sub cairo_pop_group(cairo_t $ctx)
        returns cairo_pattern_t
        is native($cairolib)
        {*}

    sub cairo_pop_group_to_source(cairo_t $ctx)
        is native($cairolib)
        {*}


    sub cairo_line_to(cairo_t $context, num64 $x, num64 $y)
        is native($cairolib)
        {*}

    sub cairo_move_to(cairo_t $context, num64 $x, num64 $y)
        is native($cairolib)
        {*}

    sub cairo_rel_line_to(cairo_t $context, num64 $x, num64 $y)
        is native($cairolib)
        {*}

    sub cairo_rel_move_to(cairo_t $context, num64 $x, num64 $y)
        is native($cairolib)
        {*}

    sub cairo_curve_to(cairo_t $context, num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3)
        is native($cairolib)
        {*}

    sub cairo_arc(cairo_t $context, num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2)
        is native($cairolib)
        {*}
    sub cairo_arc_negative(cairo_t $context, num64 $xc, num64 $yc, num64 $radius, num64 $angle1, num64 $angle2)
        is native($cairolib)
        {*}

    sub cairo_close_path(cairo_t $context)
        is native($cairolib)
        {*}

    sub cairo_new_path(cairo_t $context)
        is native($cairolib)
        {*}

    sub cairo_rectangle(cairo_t $ctx, num64 $x, num64 $y, num64 $w, num64 $h)
        is native($cairolib)
        {*}


    sub cairo_set_source_rgb(cairo_t $context, num64 $r, num64 $g, num64 $b)
        is native($cairolib)
        {*}

    sub cairo_set_source_rgba(cairo_t $context, num64 $r, num64 $g, num64 $b, num64 $a)
        is native($cairolib)
        {*}

    sub cairo_set_source(cairo_t $context, cairo_pattern_t $pat)
        is native($cairolib)
        {*}

    sub cairo_set_line_cap(cairo_t $context, int32 $cap)
        is native($cairolib)
        {*}

    sub cairo_get_line_cap(cairo_t $context)
        returns int32
        is native($cairolib)
        {*}

    sub cairo_set_line_join(cairo_t $context, int32 $join)
        is native($cairolib)
        {*}

    sub cairo_get_line_join(cairo_t $context)
        returns int32
        is native($cairolib)
        {*}

    sub cairo_set_fill_rule(cairo_t $context, int32 $cap)
        is native($cairolib)
        {*}

    sub cairo_get_fill_rule(cairo_t $context)
        returns int32
        is native($cairolib)
        {*}

    sub cairo_set_line_width(cairo_t $context, num64 $width)
        is native($cairolib)
        {*}
    sub cairo_get_line_width(cairo_t $context)
        returns num64
        is native($cairolib)
        {*}

    sub cairo_set_dash(cairo_t $context, CArray[num64] $dashes, int32 $len, num64 $offset)
        is native($cairolib)
        {*}

    sub cairo_get_operator(cairo_t $context)
        returns int32
        is native($cairolib)
        {*}
    sub cairo_set_operator(cairo_t $context, int32 $op)
        is native($cairolib)
        {*}

    sub cairo_get_antialias(cairo_t $context)
        returns int32
        is native($cairolib)
        {*}
    sub cairo_set_antialias(cairo_t $context, int32 $op)
        is native($cairolib)
        {*}

    sub cairo_set_source_surface(cairo_t $context, cairo_surface_t $surface, num64 $x, num64 $y)
        is native($cairolib)
        {*}

    sub cairo_mask(cairo_t $context, cairo_pattern_t $pattern)
        is native($cairolib)
        {*}
    sub cairo_mask_surface(cairo_t $context, cairo_surface_t $surface, num64 $sx, num64 $sy)
        is native($cairolib)
        {*}

    sub cairo_clip(cairo_t $context)
        is native($cairolib)
        {*}
    sub cairo_clip_preserve(cairo_t $context)
        is native($cairolib)
        {*}

    sub cairo_fill(cairo_t $ctx)
        is native($cairolib)
        {*}

    sub cairo_stroke(cairo_t $ctx)
        is native($cairolib)
        {*}

    sub cairo_fill_preserve(cairo_t $ctx)
        is native($cairolib)
        {*}

    sub cairo_stroke_preserve(cairo_t $ctx)
        is native($cairolib)
        {*}

    sub cairo_paint(cairo_t $ctx)
        is native($cairolib)
        {*}
    sub cairo_paint_with_alpha(cairo_t $ctx, num64 $alpha)
        is native($cairolib)
        {*}

    sub cairo_translate(cairo_t $ctx, num64 $tx, num64 $ty)
        is native($cairolib)
        {*}
    sub cairo_scale(cairo_t $ctx, num64 $sx, num64 $sy)
        is native($cairolib)
        {*}
    sub cairo_rotate(cairo_t $ctx, num64 $angle)
        is native($cairolib)
        {*}
    sub cairo_transform(cairo_t $ctx, cairo_matrix_t $matrix)
        is native($cairolib)
        {*}
    sub cairo_identity_matrix(cairo_t $ctx)
        is native($cairolib)
        {*}
    sub cairo_set_matrix(cairo_t $ctx, cairo_matrix_t $matrix)
        is native($cairolib)
        {*}
    sub cairo_get_matrix(cairo_t $ctx, cairo_matrix_t $matrix)
        is native($cairolib)
        {*}

    sub cairo_save(cairo_t $ctx)
        is native($cairolib)
        {*}
    sub cairo_restore(cairo_t $ctx)
        is native($cairolib)
        {*}

    sub cairo_status(cairo_t $ctx)
        returns int32
        is native($cairolib)
        {*}


    sub cairo_select_font_face(cairo_t $ctx, Str $family, int32 $slant, int32 $weight)
        is native($cairolib)
        {*}

    sub cairo_set_font_size(cairo_t $ctx, num64 $size)
        is native($cairolib)
        {*}

    sub cairo_show_text(cairo_t $ctx, Str $utf8)
        is native($cairolib)
        {*}

    sub cairo_text_path(cairo_t $ctx, Str $utf8)
        is native($cairolib)
        {*}

    sub cairo_text_extents(cairo_t $ctx, Str $utf8, cairo_text_extents_t $extents)
        is native($cairolib)
        {*}

    sub cairo_font_extents(cairo_t $ctx, cairo_font_extents_t $extents)
        is native($cairolib)
        {*}


    has cairo_t $!context;

    multi method new(cairo_t $context) {
        self.bless(:$context);
    }

    multi method new(Surface $surface) {
        my $context = cairo_create($surface.surface);
        self.bless(:$context);
    }

    method status {
        cairo_status_t(cairo_status($!context))
    }

    submethod BUILD(:$!context) { }

    method destroy() {
        cairo_destroy($!context)
    }


    method push_group() {
        cairo_push_group($!context);
    }

    method pop_group() returns Pattern {
        Pattern.new(cairo_pop_group($!context));
    }

    method pop_group_to_source() {
        cairo_pop_group_to_source($!context);
    }

    method sub_path() {
        cairo_new_sub_path($!context);
    }
    multi method copy_path() {
        cairo_copy_path($!context);
    }
    multi method copy_path(:$flat! where .so) {
        cairo_copy_path_flat($!context);
    }
    method append_path($path) {
        cairo_append_path($!context, $path)
    }

    method memoize_path($storage is rw, &creator, :$flat?) {
        if defined $storage {
            self.append_path($storage);
        } else {
            &creator();
            $storage = self.copy_path(:$flat);
        }
    }

    method save()    { cairo_save($!context) }
    method restore() { cairo_restore($!context) }

    multi method rgb(Cool $r, Cool $g, Cool $b) {
        cairo_set_source_rgb($!context, $r.Num, $g.Num, $b.Num);
    }
    multi method rgb(num $r, num $g, num $b) {
        cairo_set_source_rgb($!context, $r, $g, $b);
    }

    multi method rgba(Cool $r, Cool $g, Cool $b, Cool $a) {
        cairo_set_source_rgba($!context, $r.Num, $g.Num, $b.Num, $a.Num);
    }
    multi method rgb(num $r, num $g, num $b, num $a) {
        cairo_set_source_rgba($!context, $r, $g, $b, $a);
    }

    method pattern(Pattern $pat) {
        cairo_set_source($!context, $pat.pattern);
    }

    method set_source_surface(Surface $surface, Cool $x = 0, Cool $y = 0) {
        cairo_set_source_surface($!context, $surface.surface, $x.Num, $y.Num)
    }

    multi method mask(Pattern $pat, Cool $sx = 0, Cool $sy = 0) {
        cairo_mask($!context, $pat.pattern, $sx.Num, $sy.Num)
    }
    multi method mask(Pattern $pat, num $sx = 0e0, num $sy = 0e0) {
        cairo_mask($!context, $pat.pattern, $sx, $sy)
    }
    multi method mask(Surface $surface, Cool $sx = 0, Cool $sy = 0) {
        cairo_mask_surface($!context, $surface.surface, $sx.Num, $sy.Num)
    }
    multi method mask(Surface $surface, num $sx = 0e0, num $sy = 0e0) {
        cairo_mask_surface($!context, $surface.surface, $sx, $sy)
    }

    multi method fill {
        cairo_fill($!context)
    }
    multi method stroke {
        cairo_stroke($!context)
    }
    multi method fill(:$preserve! where .so) {
        cairo_fill_preserve($!context);
    }
    multi method stroke(:$preserve! where .so) {
        cairo_stroke_preserve($!context);
    }
    multi method clip {
        cairo_clip($!context);
    }
    multi method clip(:$preserve! where .so) {
        cairo_clip_preserve($!context);
    }

    method paint {
        cairo_paint($!context)
    }

    multi method paint_with_alpha( num64 $alpha) {
        cairo_paint_with_alpha($!context, $alpha)
    }
    multi method paint_with_alpha( Num(Cool) $alpha) {
        cairo_paint_with_alpha($!context, $alpha)
    }

    multi method move_to(Cool $x, Cool $y) {
        cairo_move_to($!context, $x.Num, $y.Num);
    }
    multi method line_to(Cool $x, Cool $y) {
        cairo_line_to($!context, $x.Num, $y.Num);
    }

    multi method move_to(Cool $x, Cool $y, :$relative! where .so) {
        cairo_rel_move_to($!context, $x.Num, $y.Num);
    }
    multi method line_to(Cool $x, Cool $y, :$relative! where .so) {
        cairo_rel_line_to($!context, $x.Num, $y.Num);
    }

    multi method curve_to(Cool $x1, Cool $y1, Cool $x2, Cool $y2, Cool $x3, Cool $y3) {
        cairo_curve_to($!context, $x1.Num, $y1.Num, $x2.Num, $y2.Num, $x3.Num, $y3.Num);
    }

    multi method arc(Cool $xc, Cool $yc, Cool $radius, Cool $angle1, Cool $angle2, :$negative! where .so) {
        cairo_arc_negative($!context, $xc.Num, $yc.Num, $radius.Num, $angle1.Num, $angle2.Num);
    }
    multi method arc(num $xc, num $yc, num $radius, num $angle1, num $angle2, :$negative! where .so) {
        cairo_arc_negative($!context, $xc, $yc, $radius, $angle1, $angle2);
    }

    multi method arc(Cool $xc, Cool $yc, Cool $radius, Cool $angle1, Cool $angle2) {
        cairo_arc($!context, $xc.Num, $yc.Num, $radius.Num, $angle1.Num, $angle2.Num);
    }
    multi method arc(num $xc, num $yc, num $radius, num $angle1, num $angle2) {
        cairo_arc($!context, $xc, $yc, $radius, $angle1, $angle2);
    }

    method close_path() {
        cairo_close_path($!context);
    }

    method new_path() {
        cairo_new_path($!context);
    }

    multi method rectangle(Cool $x, Cool $y, Cool $w, Cool $h) {
        cairo_rectangle($!context, $x.Num, $y.Num, $w.Num, $h.Num);
    }
    multi method rectangle(num $x, num $y, num $w, num $h) {
        cairo_rectangle($!context, $x, $y, $w, $h);
    }

    multi method translate(num $tx, num $ty) {
        cairo_translate($!context, $tx, $ty)
    }
    multi method translate(Cool $tx, Cool $ty) {
        cairo_translate($!context, $tx.Num, $ty.Num)
    }

    multi method scale(num $sx, num $sy) {
        cairo_scale($!context, $sx, $sy)
    }
    multi method scale(Cool $sx, Cool $sy) {
        cairo_scale($!context, $sx.Num, $sy.Num)
    }

    method identity_matrix {
        cairo_identity_matrix($!context);
    }

    multi method rotate(num $angle) {
        cairo_rotate($!context, $angle)
    }
    multi method rotate(Cool $angle) {
        cairo_rotate($!context, $angle.Num)
    }

    method transform(cairo_matrix_t $matrix) {
        cairo_transform($!context, $matrix)
    }

    multi method select_font_face(str $family, int32 $slant, int32 $weight) {
        cairo_select_font_face($!context, $family, $slant, $weight);
    }
    multi method select_font_face(Str(Cool) $family, Int(Cool) $slant, Int(Cool) $weight) {
        cairo_select_font_face($!context, $family, $slant, $weight);
    }

    multi method set_font_size(num $size) {
        cairo_set_font_size($!context, $size);
    }
    multi method set_font_size(Num(Cool) $size) {
        cairo_set_font_size($!context, $size);
    }

    multi method show_text(str $text) {
        cairo_show_text($!context, $text);
    }
    multi method show_text(Str(Cool) $text) {
        cairo_show_text($!context, $text);
    }

    multi method text_path(str $text) {
        cairo_text_path($!context, $text);
    }
    multi method text_path(Str(Cool) $text) {
        cairo_text_path($!context, $text);
    }

    multi method text_extents(str $text --> cairo_text_extents_t) {
        my cairo_text_extents_t $extents .= new;
        cairo_text_extents($!context, $text, $extents);
        $extents;
    }
    multi method text_extents(Str(Cool) $text --> cairo_text_extents_t) {
        my cairo_text_extents_t $extents .= new;
        cairo_text_extents($!context, $text, $extents);
        $extents;
    }

    method font_extents {
        my cairo_font_extents_t $extents .= new;
        cairo_font_extents($!context, $extents);
        $extents;
    }

    multi method set_dash(CArray[num64] $dashes, int32 $len, num64 $offset) {
        cairo_set_dash($!context, $dashes, $len, $offset);
    }
    multi method set_dash(List $dashes, Int(Cool) $len, Num(Cool) $offset) {
        my $d = CArray[num64].new;
        $d[$_] = $dashes[$_].Num
            for 0 ..^ $len;
        cairo_set_dash($!context, $d, $len, $offset);
    }

    method line_cap() {
        Proxy.new:
            FETCH => { LineCap(cairo_get_line_cap($!context)) },
            STORE => -> \c, \value { cairo_set_line_cap($!context, value.Int) }
    }

    method fill_rule() {
        Proxy.new:
            FETCH => { LineCap(cairo_get_fill_rule($!context)) },
            STORE => -> \c, \value { cairo_set_fill_rule($!context, value.Int) }
    }

    method line_join() {
        Proxy.new:
            FETCH => { LineJoin(cairo_get_line_join($!context)) },
            STORE => -> \c, \value { cairo_set_line_join($!context, value.Int) }
    }

    method operator() {
        Proxy.new:
            FETCH => { Operator(cairo_get_operator($!context)) },
            STORE => -> \c, \value { cairo_set_operator($!context, value.Int) }
    }

    method antialias() {
        Proxy.new:
            FETCH => { Antialias(cairo_get_antialias($!context)) },
            STORE => -> \c, \value { cairo_set_antialias($!context, value.Int) }
    }

    method line_width() {
        Proxy.new:
            FETCH => { cairo_get_line_width($!context) },
            STORE => -> \c, \value { cairo_set_line_width($!context, value.Num) }
    }

    method matrix() {
        Proxy.new:
            FETCH => {
                my cairo_matrix_t $matrix .= new;
                cairo_get_matrix($!context, $matrix);
                $matrix;
            },
            STORE => -> \c, cairo_matrix_t \matrix { cairo_set_matrix($!context, matrix) }
    }
}

}
