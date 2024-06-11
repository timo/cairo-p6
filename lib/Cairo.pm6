unit module Cairo:ver<0.3.5>;

our $cairolib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $cairolib = 'libcairo-2';
    } else {
        $cairolib = ('cairo', v2);
    }
}

use NativeCall;

our enum cairo_status_t is export <
    CAIRO_STATUS_SUCCESS

    CAIRO_STATUS_NO_MEMORY
    CAIRO_STATUS_INVALID_RESTORE
    CAIRO_STATUS_INVALID_POP_GROUP
    CAIRO_STATUS_NO_CURRENT_POINT
    CAIRO_STATUS_INVALID_MATRIX
    CAIRO_STATUS_INVALID_STATUS
    CAIRO_STATUS_NULL_POINTER
    CAIRO_STATUS_INVALID_STRING
    CAIRO_STATUS_INVALID_PATH_DATA
    CAIRO_STATUS_READ_ERROR
    CAIRO_STATUS_WRITE_ERROR
    CAIRO_STATUS_SURFACE_FINISHED
    CAIRO_STATUS_SURFACE_TYPE_MISMATCH
    CAIRO_STATUS_PATTERN_TYPE_MISMATCH
    CAIRO_STATUS_INVALID_CONTENT
    CAIRO_STATUS_INVALID_FORMAT
    CAIRO_STATUS_INVALID_VISUAL
    CAIRO_STATUS_FILE_NOT_FOUND
    CAIRO_STATUS_INVALID_DASH
    CAIRO_STATUS_INVALID_DSC_COMMENT
    CAIRO_STATUS_INVALID_INDEX
    CAIRO_STATUS_CLIP_NOT_REPRESENTABLE
    CAIRO_STATUS_TEMP_FILE_ERROR
    CAIRO_STATUS_INVALID_STRIDE
    CAIRO_STATUS_FONT_TYPE_MISMATCH
    CAIRO_STATUS_USER_FONT_IMMUTABLE
    CAIRO_STATUS_USER_FONT_ERROR
    CAIRO_STATUS_NEGATIVE_COUNT
    CAIRO_STATUS_INVALID_CLUSTERS
    CAIRO_STATUS_INVALID_SLANT
    CAIRO_STATUS_INVALID_WEIGHT
    CAIRO_STATUS_INVALID_SIZE
    CAIRO_STATUS_USER_FONT_NOT_IMPLEMENTED
    CAIRO_STATUS_DEVICE_TYPE_MISMATCH
    CAIRO_STATUS_DEVICE_ERROR
    CAIRO_STATUS_INVALID_MESH_CONSTRUCTION
    CAIRO_STATUS_DEVICE_FINISHED

    CAIRO_STATUS_LAST_STATUS
>;

our enum CairoStatus is export <
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

our enum cairo_path_data_type_t is export <
  CAIRO_PATH_MOVE_TO
  CAIRO_PATH_LINE_TO
  CAIRO_PATH_CURVE_TO
  CAIRO_PATH_CLOSE_PATH
>;

our enum PathDataTypes is export <
  PATH_MOVE_TO
  PATH_LINE_TO
  PATH_CURVE_TO
  PATH_CLOSE_PATH
>;

our enum cairo_tag_t is export (
    :CAIRO_TAG_DEST<cairo.dest>,
    :CAIRO_TAG_LINK<Link>,
);

our enum cairo_pdf_outline_flags_t is export (
    :CAIRO_PDF_OUTLINE_FLAG_OPEN(0x1),
    :CAIRO_PDF_OUTLINE_FLAG_BOLD(0x2),
    :CAIRO_PDF_OUTLINE_FLAG_ITALIC(0x4),
);

our enum cairo_pdf_metadata_t is export <
    CAIRO_PDF_METADATA_TITLE
    CAIRO_PDF_METADATA_AUTHOR
    CAIRO_PDF_METADATA_SUBJECT
    CAIRO_PDF_METADATA_KEYWORDS
    CAIRO_PDF_METADATA_CREATOR
    CAIRO_PDF_METADATA_CREATE_DATE
    CAIRO_PDF_METADATA_MOD_DATE
>;

sub cairo_version_string
        returns Str
        is native($cairolib)
        {*}

our sub version {
    Version.new: cairo_version_string()
}

my class StreamClosure is repr('CStruct') is rw {

    sub memcpy(Pointer[uint8] $dest, Pointer[uint8] $src, size_t $n)
        is native
        {*}

    has CArray[uint8] $!buf;
    has size_t $.buf-len;
    has size_t $.n-read;
    has size_t $.size;
    submethod TWEAK(CArray :$buf!) { $!buf := $buf }
    method buf-pointer( --> Pointer[uint8]) {
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

module Attrs {
    sub attr-value($_) {
        when List { '[' ~ .map(&attr-value).join(' ') ~ ']' }
        when Bool  { $_ ?? 'true' !! 'false'}
        when Int  { .Str }
        when Numeric {
            my Str $num = .fmt('%.5f');
            $num ~~ s/(\.\d*?)0+$/$0/;
            $num .= chop if $num.ends-with('.');
            $num
        }
        when Str {
            q{'} ~ .trans("\\" => "\\\\", "'" => "\\'") ~ q{'};
        }
        default {
            warn "unsupported attribute value: {.raku}";
            ''
        }
    }

    our sub serialize(%attrs) {
        join ' ', %attrs.sort.map: {
            .value.defined
            ?? .key ~ '=' ~ attr-value(.value)
            !! Empty
        }
    }
}

our class cairo_surface_t is repr('CPointer') {

    method status
        returns uint32
        is native($cairolib)
        is symbol('cairo_surface_status')
        {*}

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

class cairo_pdf_surface_t is cairo_surface_t is repr('CPointer') {

    our sub create(str $filename, num64 $width, num64 $height)
        returns cairo_pdf_surface_t
        is native($cairolib)
        is symbol('cairo_pdf_surface_create')
        {*}


    method add_outline(int32 $parent-id, Str $name, Str $link-attrs, int32 $flags --> int32)
        is native($cairolib)
        is symbol('cairo_pdf_surface_add_outline')
        {*}

    method set_metadata(int32 $type, Str $value)
        is native($cairolib)
        is symbol('cairo_pdf_surface_set_metadata')
        {*}

    method new(Str:D :$filename!, Num:D() :$width!, Num:D() :$height! --> cairo_pdf_surface_t:D) {
        create($filename, $width, $height);
    }
}

class cairo_svg_surface_t is cairo_surface_t is repr('CPointer') {
    our sub create(str $filename, num64 $width, num64 $height)
        returns cairo_svg_surface_t
        is native($cairolib)
        is symbol('cairo_svg_surface_create')
        {*}

    method new(Str:D :$filename!, Num:D() :$width!, Num:D() :$height! --> cairo_svg_surface_t) {
        create($filename, $width, $height);
    }
}

our class cairo_rectangle_t is repr('CPointer') { }

our class cairo_path_data_header_t  is repr('CStruct') {
  has uint32     $.type;
  has int32      $.length;
}
our class cairo_path_data_point_t is repr('CStruct') {
  has num64 $.x is rw;
  has num64 $.y is rw;
}
our class cairo_path_data_t is repr('CUnion') is export {
  HAS cairo_path_data_header_t $.header;
  HAS cairo_path_data_point_t  $.point;

  method data-type { PathDataTypes( self.header.type ) }
  method length    { self.header.length                }
  method x is rw   { self.point.x                      }
  method y is rw   { self.point.y                      }
}

our class cairo_path_t is repr('CStruct') is export {
  has uint32                     $.status;   # cairo_path_data_type_t
  has Pointer[cairo_path_data_t] $.data;
  has int32                      $.num_data;

  sub path_destroy(cairo_path_t)
    is symbol('cairo_path_destroy')
    is native($cairolib)
    {*}

  method destroy {
    path_destroy(self);
  }
}

our class cairo_text_extents_t is repr('CStruct') {
    has num64 $.x_bearing is rw;
    has num64 $.y_bearing is rw;
    has num64 $.width     is rw;
    has num64 $.height    is rw;
    has num64 $.x_advance is rw;
    has num64 $.y_advance is rw;
}

our class cairo_font_extents_t is repr('CStruct') {
    has num64 $.ascent        is rw;
    has num64 $.descent       is rw;
    has num64 $.height        is rw;
    has num64 $.max_x_advance is rw;
    has num64 $.max_y_advance is rw;
}

our class cairo_rectangle_int_t is repr('CStruct') {
    has int32 $.x      is rw;
    has int32 $.y      is rw;
    has int32 $.width  is rw;
    has int32 $.height is rw;
}

our class cairo_font_face_t is repr('CPointer') {

   method reference
        is native($cairolib)
        is symbol('cairo_font_face_reference')
        {*}
   method destroy
        is native($cairolib)
        is symbol('cairo_font_face_destroy')
        {*}
}

our class cairo_scaled_font_t is repr('CPointer') {

   method reference
        is native($cairolib)
        is symbol('cairo_scaled_font_reference')
        {*}
   method destroy
        is native($cairolib)
        is symbol('cairo_scaled_font_destroy')
        {*}
}

our class cairo_glyph_t is repr('CStruct') {
    has ulong $.index is rw;
    has num64 $.x     is rw ;
    has num64 $.y     is rw;

    sub cairo_glyph_allocate(int32 $num_glyphs)
        returns cairo_glyph_t
        is native($cairolib)
        {*}

    method allocate(UInt $num_glyphs) {
        cairo_glyph_allocate($num_glyphs);
    }

    method free
        is native($cairolib)
        is symbol('cairo_glyph_free')
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

    method get_color_stop_count(int32 $count is rw)
      returns int32
      is native($cairolib)
      is symbol('cairo_pattern_get_color_stop_count')
      {*}

    method get_color_stop_rgba(
      int32 $index,
      num64 $o      is rw,
      num64 $r      is rw,
      num64 $g      is rw,
      num64 $b      is rw
    )
      returns int32
      is native($cairolib)
      is symbol('cairo_pattern_get_color_stop_rgba')
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

class cairo_font_options_t is repr('CPointer') {

    method copy
        returns cairo_font_options_t
        is native($cairolib)
        is symbol('cairo_font_options_create')
        {*}

    method destroy
        is native($cairolib)
        is symbol('cairo_font_options_destroy')
        {*}

    method status
        returns uint32
        is native($cairolib)
        is symbol('cairo_font_options_status')
        {*}

    method merge(cairo_font_options_t $other)
        is native($cairolib)
        is symbol('cairo_font_options_merge')
        {*}

    method hash
        returns uint64
        is native($cairolib)
        is symbol('cairo_font_options_hash')
        {*}

    method equal(cairo_font_options_t $opts)
        returns uint32
        is native($cairolib)
        is symbol('cairo_font_options_equal')
        {*}

    method set_antialias(uint32 $aa)
        is native($cairolib)
        is symbol('cairo_font_options_set_antialias')
        {*}

    method get_antialias
        returns uint32
        is native($cairolib)
        is symbol('cairo_font_options_get_antialias')
        {*}

    method set_subpixel_order(uint32 $order)
        is native($cairolib)
        is symbol('cairo_font_options_create_subpixel_order')
        {*}

    method get_subpixel_order
        returns uint32
        is native($cairolib)
        is symbol('cairo_font_options_create_get_subpixel_order')
        {*}

    method set_hint_style(uint32 $style)
        is native($cairolib)
        is symbol('cairo_font_options_set_hint_style')
        {*}

    method get_hint_style
        returns uint32
        is native($cairolib)
        is symbol('cairo_font_options_get_hint_style')
        {*}

    method set_hint_metrics(uint32 $metrics)
        is native($cairolib)
        is symbol('cairo_font_options_set_hint_metrics')
        {*}

    method get_hint_metrics
        returns uint32
        is native($cairolib)
        is symbol('cairo_font_options_get_hint_metrics')
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


    method get_current_point(num64 $x is rw, num64 $y is rw)
        is native($cairolib)
        is symbol('cairo_get_current_point')
        {*}
    method line_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_line_to')
        {*}

    method move_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_move_to')
        {*}

    method curve_to(num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3)
        is native($cairolib)
        is symbol('cairo_curve_to')
        {*}

    method rel_line_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_rel_line_to')
        {*}

    method rel_move_to(num64 $x, num64 $y)
        is native($cairolib)
        is symbol('cairo_rel_move_to')
        {*}

    method rel_curve_to(num64 $x1, num64 $y1, num64 $x2, num64 $y2, num64 $x3, num64 $y3)
        is native($cairolib)
        is symbol('cairo_rel_curve_to')
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

    method set_miter_limit(num64 $width)
        is native($cairolib)
        is symbol('cairo_set_miter_limit')
        {*}
    method get_miter_limit
        returns num64
        is native($cairolib)
        is symbol('cairo_get_miter_limit')
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

    method get_font_face
        returns cairo_font_face_t
        is native($cairolib)
        is symbol('cairo_get_font_face')
        {*}

    method set_font_size(num64 $size)
        is native($cairolib)
        is symbol('cairo_set_font_size')
        {*}

    method set_scaled_font(cairo_scaled_font_t $font)
        is native($cairolib)
        is symbol('cairo_set_scaled_font')
        {*}

    method get_scaled_font
        returns cairo_scaled_font_t
        is native($cairolib)
        is symbol('cairo_get_scaled_font')
        {*}

    method show_text(Str $utf8)
        is native($cairolib)
        is symbol('cairo_show_text')
        {*}

    method text_path(Str $utf8)
        is native($cairolib)
        is symbol('cairo_text_path')
        {*}

    method show_glyphs(cairo_glyph_t $glyphs, int32 $len)
        is native($cairolib)
        is symbol('cairo_show_glyphs')
        {*}

    method glyph_path(cairo_glyph_t $glyphs, int32 $len)
        is native($cairolib)
        is symbol('cairo_glyph_path')
        {*}

    method text_extents(Str $utf8, cairo_text_extents_t $extents)
        is native($cairolib)
        is symbol('cairo_text_extents')
        {*}

    method font_extents(cairo_font_extents_t $extents)
        is native($cairolib)
        is symbol('cairo_font_extents')
        {*}

    method set_tolerance(num64 $tolerance)
        is native($cairolib)
        is symbol('cairo_set_tolerance')
        {*}

    method get_tolerance()
        returns num64
        is native($cairolib)
        is symbol('cairo_get_tolerance')
        {*}

    method set_font_options(cairo_font_options_t $options)
        is native($cairolib)
        is symbol('cairo_set_font_options')
        {*}
    method get_font_options()
        is native($cairolib)
        is symbol('cairo_get_font_options')
        {*}

    method tag_begin(Str $tag, Str $attrs)
        is native($cairolib)
        is symbol('cairo_tag_begin')
        {*}

    method tag_end(Str $tag)
        is native($cairolib)
        is symbol('cairo_tag_end')
        {*}

}

# Backwards compatibility
our enum cairo_subpixel_order_t is export <
    CAIRO_SUBPIXEL_ORDER_DEFAULT,
    CAIRO_SUBPIXEL_ORDER_RGB,
    CAIRO_SUBPIXEL_ORDER_BGR,
    CAIRO_SUBPIXEL_ORDER_VRGB,
    CAIRO_SUBPIXEL_ORDER_VBGR
>;

our enum SubpixelOrder is export <
    SUBPIXEL_ORDER_DEFAULT
    SUBPIXEL_ORDER_RGB
    SUBPIXEL_ORDER_BGR
    SUBPIXEL_ORDER_VRGB
    SUBPIXEL_ORDER_VBGR
>;

our enum cairo_hint_style_t is export <
    CAIRO_HINT_STYLE_DEFAULT
    CAIRO_HINT_STYLE_NONE
    CAIRO_HINT_STYLE_SLIGHT
    CAIRO_HINT_STYLE_MEDIUM
    CAIRO_HINT_STYLE_FULL
>;

our enum HintStyle is export <
    HINT_STYLE_DEFAULT
    HINT_STYLE_NONE
    HINT_STYLE_SLIGHT
    HINT_STYLE_MEDIUM
    HINT_STYLE_FULL
>;

our enum cairo_hint_metrics_t is export <
    CAIRO_HINT_METRICS_DEFAULT
    CAIRO_HINT_METRICS_OFF
    CAIRO_HINT_METRICS_ON
>;

our enum HintMetrics is export <
    HINT_METRICS_DEFAULT
    HINT_METRICS_OFF
    HINT_METRICS_ON
>;

our enum cairo_antialias_t is export <
  CAIRO_ANTIALIAS_DEFAULT
  CAIRO_ANTIALIAS_NONE
  CAIRO_ANTIALIAS_GRAY
  CAIRO_ANTIALIAS_SUBPIXEL
  CAIRO_ANTIALIAS_FAST
  CAIRO_ANTIALIAS_GOOD
  CAIRO_ANTIALIAS_BEST
>;

our class Matrix  { ... }
our class Surface { ... }
our class Image   { ... }
our class Pattern { ... }
our class Context { ... }
our class Font    { ... }
our class FontOptions { ... }
our class ScaledFont  { ... }

# Backwards compatibility
our enum cairo_format_t is export (
  CAIRO_FORMAT_INVALID   => -1,
  CAIRO_FORMAT_ARGB32    => 0,
  CAIRO_FORMAT_RGB24     => 1,
  CAIRO_FORMAT_A8        => 2,
  CAIRO_FORMAT_A1        => 3,
  CAIRO_FORMAT_RGB16_565 => 4,
  CAIRO_FORMAT_RGB30     => 5
);

our enum Format is export (
     FORMAT_INVALID => -1,
    "FORMAT_ARGB32"   ,
    "FORMAT_RGB24"    ,
    "FORMAT_A8"       ,
    "FORMAT_A1"       ,
    "FORMAT_RGB16_565",
    "FORMAT_RGB30"    ,
);

# Backwards compatibility
our enum cairo_operator_t is export <
  CAIRO_OPERATOR_CLEAR
  CAIRO_OPERATOR_SOURCE
  CAIRO_OPERATOR_OVER
  CAIRO_OPERATOR_IN
  CAIRO_OPERATOR_OUT
  CAIRO_OPERATOR_ATOP
  CAIRO_OPERATOR_DEST
  CAIRO_OPERATOR_DEST_OVER
  CAIRO_OPERATOR_DEST_IN
  CAIRO_OPERATOR_DEST_OUT
  CAIRO_OPERATOR_DEST_ATOP
  CAIRO_OPERATOR_XOR
  CAIRO_OPERATOR_ADD
  CAIRO_OPERATOR_SATURATE
  CAIRO_OPERATOR_MULTIPLY
  CAIRO_OPERATOR_SCREEN
  CAIRO_OPERATOR_OVERLAY
  CAIRO_OPERATOR_DARKEN
  CAIRO_OPERATOR_LIGHTEN
  CAIRO_OPERATOR_COLOR_DODGE
  CAIRO_OPERATOR_COLOR_BURN
  CAIRO_OPERATOR_HARD_LIGHT
  CAIRO_OPERATOR_SOFT_LIGHT
  CAIRO_OPERATOR_DIFFERENCE
  CAIRO_OPERATOR_EXCLUSION
  CAIRO_OPERATOR_HSL_HUE
  CAIRO_OPERATOR_HSL_SATURATION
  CAIRO_OPERATOR_HSL_COLOR
  CAIRO_OPERATOR_HSL_LUMINOSITY
>;

our enum CairoOperator is export <
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

our enum cairo_line_cap is export <
  CAIRO_LINE_CAP_BUTT
  CAIRO_LINE_CAP_ROUND
  CAIRO_LINE_CAP_SQUARE
>;

our enum LineCap is export <
    LINE_CAP_BUTT
    LINE_CAP_ROUND
    LINE_CAP_SQUARE
>;

our enum cairo_line_join is export <
    CAIRO_LINE_JOIN_MITER
    CAIRO_LINE_JOIN_ROUND
    CAIRO_LINE_JOIN_BEVEL
>;

our enum LineJoin is export <
    LINE_JOIN_MITER
    LINE_JOIN_ROUND
    LINE_JOIN_BEVEL
>;

our enum Content is export (
    CONTENT_COLOR => 0x1000,
    CONTENT_ALPHA => 0x2000,
    CONTENT_COLOR_ALPHA => 0x3000,
);

our enum Antialias is export <
    ANTIALIAS_DEFAULT
    ANTIALIAS_NONE
    ANTIALIAS_GRAY
    ANTIALIAS_SUBPIXEL
    ANTIALIAS_FAST
    ANTIALIAS_GOOD
    ANTIALIAS_BEST
>;

our enum FontWeight is export <
    FONT_WEIGHT_NORMAL
    FONT_WEIGHT_BOLD
>;

our enum FontSlant is export <
    FONT_SLANT_NORMAL
    FONT_SLANT_ITALIC
    FONT_SLANT_OBLIQUE
>;

our enum Extend is export <
    EXTEND_NONE
    EXTEND_REPEAT
    EXTEND_REFLECT
    CAIRO_EXTEND_PAD
>;

our enum FillRule is export <
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
    has cairo_surface_t $.surface handles <reference destroy flush finish show_page status>;
    method set-surface($!surface) {}

    method write_png(Str $filename) {
        my $result = CairoStatus( $.surface.write_to_png($filename) );
        fail $result if $result != STATUS_SUCCESS;
        $result;
    }

    method Blob(UInt :$size = 64_000 --> Blob) {
         my $buf = CArray[uint8].new;
         $buf[$size] = 0;
         my $closure = StreamClosure.new: :$buf, :buf-len(0), :n-read(0), :$size;
         $.surface.write_to_png_stream(&StreamClosure::write, $closure);
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
    has Num:D() $.width is required;
    has Num:D() $.height is required;

    submethod BUILD(Str:D() :$filename!, :$!width!, :$!height!) is hidden-from-backtrace {
        my $s = cairo_pdf_surface_t::create($filename, $!width, $!height);
        self.set-surface: $s;
    }

    method create(Str:D() $filename, Str:D() $width, Str:D() $height) {
        return self.new( :$filename, :$width, :$height );
    }

    method add_outline(Int :$parent-id, Str:D :$name = '', :$flags = 0, *%attrs) {
        $.surface.add_outline: $parent-id, $name, Attrs::serialize(%attrs), $flags;
    }

    method surface returns cairo_pdf_surface_t handles<set_metadata> { callsame() }
}

class Surface::SVG is Surface {
    has Num:D() $.width is required;
    has Num:D() $.height is required;

    submethod BUILD(Str:D() :$filename!, :$!width!, :$!height!) is hidden-from-backtrace {
        self.set-surface: cairo_svg_surface_t::create $filename, $!width, $!height;
    }

    method create(Str:D() $filename, Int:D() $width, Int:D() $height) {
        return self.new(:$filename, :$width, :$height);
    }

    method surface returns cairo_svg_surface_t { callsame }

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

    sub cairo_image_surface_create_for_data_ca(CArray[uint8] $data, int32 $format, int32 $width, int32 $height, int32 $stride)
        returns cairo_surface_t
        is native($cairolib)
        {*}
    sub cairo_image_surface_create_for_data_b(Blob[uint8] $data, int32 $format, int32 $width, int32 $height, int32 $stride)
        returns cairo_surface_t
        is native($cairolib)
        {*}
    sub cairo_image_surface_create_for_data(Pointer $data, int32 $format, int32 $width, int32 $height, int32 $stride)
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

    multi submethod BUILD(cairo_surface_t:D :$surface) is hidden-from-backtrace { self.set-surface: $surface}
    multi submethod BUILD(Str:D :$filename!) is hidden-from-backtrace {
        self.set-surface: cairo_image_surface_create_from_png($filename)
    }
    multi submethod BUILD(Int:D() :$width!, Int:D() :$height!, Int:D() :$format = Cairo::FORMAT_ARGB32) is hidden-from-backtrace {
        self.set-surface: cairo_image_surface_create($format, $width, $height);
    }

    multi method create(Int() $format, Cool $width, Cool $height) {
        return self.new(surface => cairo_image_surface_create($format.Int, $width.Int, $height.Int));
    }

    multi method create(Int() $format, Cool $width, Cool $height, $data, Cool $stride? is copy) {
        if $stride eqv False {
            $stride = $width.Int;
        } elsif $stride eqv True {
            $stride = cairo_format_stride_for_width($format.Int, $width.Int);
        }
        my $d = do given $data {
          when Array[uint8]     { my $tmp = CArray[uint8].new($_);
                                  $_ = $tmp;
                                  proceed; }
          when Buf[uint8]       { my $tmp = nativecast(Blob[uint8], $_);
                                  $_ = $tmp;
                                  proceed; }
          when CArray[uint8]  |
               Blob[uint8]    |
               Pointer          { $_ }

          default {
            die qq:to/D/;
              Invalid type: { .^name }
              Cairo::Image.create only supports variables of type: {
              '' }Array[uint8], CArray[uint8], Blob[uint8] and Pointer.
              D
          }
        }
        return self.new(surface => do given $d {
          when CArray  { cairo_image_surface_create_for_data_ca($d, $format.Int, $width.Int, $height.Int, $stride) }
          when Blob    { cairo_image_surface_create_for_data_b($d, $format.Int, $width.Int, $height.Int, $stride) }
          when Pointer { cairo_image_surface_create_for_data($d, $format.Int, $width.Int, $height.Int, $stride) }
        });
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
class Glyphs {...}

class Pattern {

    has cairo_pattern_t $.pattern handles <destroy>;

    method Cairo::cairo_pattern_t { $!pattern }

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

    method add_color_stop_rgb(Num(Cool) $offset, Num(Cool) $red, Num(Cool) $green, Num(Cool) $blue) {
        my num64 ($o, $r, $g, $b) = ($offset, $red, $green, $blue);
        say "o = $offset / r = $r / g = $g / b = $b";
        $.pattern.add_color_stop_rgb($o, $r, $g, $b);
    }

    method add_color_stop_rgba(Num(Cool) $offset, Num(Cool) $r, Num(Cool) $g, Num(Cool) $b, Num(Cool) $a) {
        say "o = $offset / r = $r / g = $g / b = $b / a = $a";
        $.pattern.add_color_stop_rgba($offset, $r, $g, $b, $a);
    }

    multi method get_color_stop_count {
      samewith($);
    }
    multi method get_color_stop_count ($count is rw) {
      my int32 $c = 0;
      $.pattern.get_color_stop_count($c);
      $count = $c;
    }
    method elems {
      self.get_color_stop_count;
    }

    multi method get_color_stop_rgba (Int() $index) {
      samewith($index, $, $, $, $);
    }
    multi method get_color_stop_rgba (
      Int() $index,
      $offset       is rw,
      $red          is rw,
      $green        is rw,
      $blue         is rw
    ) {
      my int32  $i              = $index;
      my num64 ($o, $r, $g, $b) = 0e0 xx 4;

      $.pattern.get_color_stop_rgba($i, $o, $r, $g, $b);
      ($offset, $red, $green, $blue) = ($o, $r, $g, $b);
    }

    method gist {
      my @stops;

      for ^self.get_color_stop_count {
        my @s = self.get_color_stop_rgba($_);
        say "Stop #{ $_ } = { @s.join(', ') }";
        @stops.push: @s;
      }

      say "Cario::Pattern::Gradient.new(stops => { @stops.join(', ') }) <not legal raku>";
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

class Path { ... }

class Context {
    sub cairo_create(cairo_surface_t $surface)
        returns cairo_t
        is native($cairolib)
        {*}

    has cairo_t $.context handles <
        status destroy push_group pop_group_to_source sub_path
        save restore paint close_path new_path identity_matrix
        tag_end
    >;

    method Cairo::cairo_t {
      $.context
    }

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

    method append_path(cairo_path_t() $path) {
      $!context.append_path($path);
    }

    multi method copy_path() {
        Path.new($!context.copy_path);
    }
    multi method copy_path(:$flat! where .so) {
        Path.new($!context.copy_path_flat)
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

    multi method get_current_point {
        my Num ($x, $y);
        samewith($x, $y);
    }
    multi method get_current_point(Num $x is rw, Num $y is rw) {
        my num64 ($xx, $yy) = (0.Num, 0.Num);
        $!context.get_current_point($xx, $yy);
        ($x, $y) = ($xx, $yy);
    }

    multi method curve_to(Num(Cool) $x1, Num(Cool) $y1, Num(Cool) $x2, Num(Cool) $y2, Num(Cool) $x3, Num(Cool) $y3) {
        $!context.curve_to($x1, $y1, $x2, $y2, $x3, $y3);
    }
    multi method curve_to(Num(Cool) $x1, Num(Cool) $y1, Num(Cool) $x2, Num(Cool) $y2, Num(Cool) $x3, Num(Cool) $y3, :$relative! where .so) {
        $!context.rel_curve_to($x1, $y1, $x2, $y2, $x3, $y3);
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
    method get_font_face {
        my $face =  $!context.get_font_face;
        $face.reference;
        Cairo::Face.new: :$face;
    }

    multi method set_font_size(num $size) {
        $!context.set_font_size($size);
    }
    multi method set_font_size(Num(Cool) $size) {
        $!context.set_font_size($size);
    }

    method set_scaled_font(Cairo::ScaledFont $font) {
        $!context.set_scaled_font($font.font);
    }
    method get_scaled_font {
        my $font =  $!context.get_scaled_font;
        $font.reference;
        Cairo::Face.new: :$font;
    }

    multi method show_text(str $text) {
        $!context.show_text($text);
    }
    multi method show_text(Str(Cool) $text) {
        $!context.show_text($text);
    }

    method show_glyphs(Glyphs $glyph_array, $n = $glyph_array.elems) {
        $!context.show_glyphs($glyph_array.glyphs, $n);
    }

    method glyph_path(Glyphs $glyph_array, $n = $glyph_array.elems) {
        $!context.glyph_path($glyph_array.glyphs, $n);
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
    multi method set_dash(@dashes, Num(Cool) $offset = 0) {
        samewith(@dashes.List, @dashes.elems, $offset);
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
            FETCH => { CairoOperator($!context.get_operator) },
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

    method miter_limit() is rw {
        Proxy.new:
            FETCH => { $!context.get_miter_limit},
            STORE => -> \c, \value { $!context.set_miter_limit(value.Num) }
    }

    method tolerance() is rw {
        Proxy.new:
            FETCH => { $!context.get_tolerance},
            STORE => -> \c, \value { $!context.set_tolerance(value.Num) }
    }
    method font_options() is rw {
        Proxy.new:
            FETCH => { $!context.get_font_options},
            STORE => -> \c, cairo_font_options_t() \value { $!context.set_font_options(value) }
    }
    method font_face() is rw {
        Proxy.new:
            FETCH => { self.get_font_face},
            STORE => -> \c, Cairo::Font() \value { self.set_font_face(value) }
    }

    method tag_begin(Str:D $tag, *%attrs) {
        $!context.tag_begin($tag, Attrs::serialize(%attrs));
    }

    # tags links, destinations; primarily for PDF backend
    method tag(Str:D $tag, &block) {
        $.tag_begin: $tag, |%_;
        &block(self);
        $.tag_end($tag);
    }

    # URI link
    multi method link_begin(Str:D :$uri!, List :$rect) {
        $.tag_begin: CAIRO_TAG_LINK, :$uri, :$rect;
    }
    # link to a named destination, in this or another PDF file
    multi method link_begin(Str:D :$dest!, Str :$file) {
        $.tag_begin: CAIRO_TAG_LINK, :$dest, :$file;
    }
    # link to a page, in this or another PDF file
    multi method link_begin(Int:D :$page!, List :$pos, Str :$file) {
        $.tag_begin: CAIRO_TAG_LINK, :$page, :$pos, :$file;
    }
    method link_end { $.tag_end(CAIRO_TAG_LINK) }
    method link(&block, |c) {
        $.link_begin: |c;
        &block();
        $.link_end;
    }

    # creates a named destination
    method destination(&block, Str:D :$name!, Numeric :$x, Numeric :$y, Bool :$internal) {
        $.tag: CAIRO_TAG_DEST, &block, :$name, :$x, :$y, :$internal;
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

class Path {
  has cairo_path_t $.path handles <data num_data>;

  submethod BUILD (:$!path) { }

  method Cairo::cairo_path_t { $.path }

  method AT-POS(|) {
    die 'Sorry! Cairo::Path is an iterated list, not an array.'
  }

  method get_data(Int $i) {
    my $a = [];
    $a[$_] := $!path.data[$i + $_] for ^$!path.data[$i].length;
    $a;
  }

  method iterator {
    my $oc = self;
    my $path = $!path;

    class :: does Iterator {
      has $.index is rw = 0;

      method pull-one {
        my $r;
        if $path.num_data > $.index {
          $r = $oc.get_data($.index);
          $.index += $r.elems;
        } else {
          $r := IterationEnd;
        }
        $r;
      }
    }.new;
  }

  method new (cairo_path_t $path) {
    self.bless(:$path);
  }

  method destroy {
    $!path.destroy;
  }
}


class Font {
    sub cairo_ft_font_face_create_for_ft_face(Pointer $ft-face, int32 $flags)
        returns cairo_font_face_t
        is native($cairolib)
        {*}

    sub cairo_ft_font_face_create_for_pattern(Pointer $fontconfig-patt)
        returns cairo_font_face_t
        is native($cairolib)
        {*}

      has cairo_font_face_t $.face handles <destroy>;
      multi method create($font-face, :free-type($)! where .so, Int :$flags = 0) {
          return self.new(
              face => cairo_ft_font_face_create_for_ft_face(
                  nativecast(Pointer, $font-face),
                  $flags )
          )
      }
      multi method create($pattern, :fontconfig($)! where .so) {
          return self.new(
              face => cairo_ft_font_face_create_for_pattern(
                  nativecast(Pointer, $pattern),
              )
          )
      }
}

class ScaledFont {
    sub cairo_scaled_font_create(cairo_font_face_t, cairo_matrix_t, cairo_matrix_t, cairo_font_options_t)
        returns cairo_scaled_font_t
        is native($cairolib)
        {*}

    has cairo_scaled_font_t $.font handles <destroy>;
    has Matrix:D $.ctm is required;
    has Matrix:D $.scale is required;
    multi method create(Font:D $font, Matrix:D $scale, Matrix:D $ctm, Cairo::FontOptions $opts = Cairo::FontOptions.new) {
        return self.new(
            :$ctm,
            :$scale,
            font => cairo_scaled_font_create(
                $font.face,
                $scale.matrix,
                $ctm.matrix,
                $opts.font_options,
            )
        )
    }
}

class FontOptions {

  sub font_options_create()
      returns cairo_font_options_t
      is native($cairolib)
      is symbol('cairo_font_options_create')
      {*}

  has cairo_font_options_t $.font_options handles <destroy hash>;

  submethod BUILD(:$!font_options) { }

  method Cairo::cairo_font_options_t {
    $.font_options;
  }

  multi method new {
    my $font_options = font_options_create();
    self.bless(:$font_options);
  }
  multi method new (cairo_font_options_t $font_options) {
    self.bless(:$font_options);
  }

  method status {
    CairoStatus( $.font_options.status );
  }

  method merge($other) {
    $.font_options.merge($other);
  }

  method equal(cairo_font_options_t $b) {
    so $.font_options.equals($b);
  }

  method antialias() is rw {
      Proxy.new:
          FETCH => { Antialias( $.font_options.get_antialias ) },
          STORE => -> \c, \value { $.font_options.set_antialias(value.Int) }
  }
  method subpixel_order() is rw {
      Proxy.new:
          FETCH => { SubpixelOrder( $.font_options.get_subpixel_order ) },
          STORE => -> \c, \value { $.font_options.set_subpixel_order(value.Int) }
  }
  method hint_style() is rw {
      Proxy.new:
          FETCH => { HintStyle( $.font_options.get_hint_style ) },
          STORE => -> \c, \value { $.font_options.set_hint_style(value.Int) }
  }
  method hint_metrics() is rw {
    Proxy.new:
          FETCH => { HintMetrics( $.font_options.get_hint_metrics ) },
          STORE => -> \c, \value { $.font_options.set_hint_metrics(value.Int) }
  }

}

class Glyphs {
    has UInt:D $.elems is required;
    has cairo_glyph_t $!glyphs; # a contiguous array of $!elems glyphs
    has Numeric ($.x-advance, $.y-advance) is rw;
    constant RecSize = nativesizeof(cairo_glyph_t);
    submethod TWEAK {
        $!glyphs = cairo_glyph_t.allocate($!elems);
    }
    method glyphs { $!glyphs }
    method AT-POS(Int:D $idx where 0 <= * < $!elems) {
        my Pointer $base-addr := nativecast(Pointer, $!glyphs);
        my Pointer $rec-addr := Pointer.new(+$base-addr  +  RecSize * $idx);
        nativecast(cairo_glyph_t, $rec-addr);
    }
    submethod DESTROY {
        $!glyphs.free;
    }
}
