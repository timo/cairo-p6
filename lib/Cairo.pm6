use NativeCall;

class cairo_t is repr('CPointer') { }

class cairo_surface_t is repr('CPointer') { }

class cairo_pattern_t is repr('CPointer') { }
 
enum Cairo::Format (
    "FORMAT_INVALID" => -1,
    "FORMAT_ARGB32"   ,
    "FORMAT_RGB24"    ,
    "FORMAT_A8"       ,
    "FORMAT_A1"       ,
    "FORMAT_RGB16_565",
    "FORMAT_RGB30"    ,
);

enum cairo_status_t <
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

sub cairo_format_stride_for_width(int $format, int $width)
    returns int
    is native('libcairo.so.2')
    {*}

class Cairo::Surface {
    has $.surface;

    sub cairo_surface_write_to_png(cairo_surface_t $surface, Str $filename)
        returns int
        is native('libcairo.so.2')
        {*}

    method write_png(Str $filename) {
        my $result = cairo_surface_write_to_png($!surface, $filename);
        fail cairo_status_t($result) if $result != STATUS_SUCCESS;
        cairo_status_t($result);
    }
}

class Cairo::Image {
    sub cairo_image_surface_create(int $format, int $width, int $height)
        returns cairo_surface_t
        is native('libcairo.so.2')
        {*}

    sub cairo_image_surface_create_for_data(Blob[uint8] $data, int $format, int $width, int $height, int $stride)
        returns cairo_surface_t
        is native('libcairo.so.2')
        {*}

    multi method create(Cairo::Format $format, Cool $width, Cool $height) {
        return Cairo::Surface.new(surface => cairo_image_surface_create($format.Int, $width.Int, $height.Int));
    }

    multi method create(Cairo::Format $format, Cool $width, Cool $height, Blob[uint8] $data, Cool $stride?) {
        if $stride eqv False {
            $stride = $width.Int;
        } elsif $stride eqv True {
            $stride = cairo_format_stride_for_width($format.Int, $width.Int);
        }
        return Cairo::Surface.new(surface => cairo_image_surface_create_for_data($data, $format.Int, $width.Int, $height.Int, $stride));
    }
}

class Cairo::Pattern {
    sub cairo_pattern_destroy(cairo_pattern_t $pat)
        is native('libcairo.so.2')
        {*}

    has $!pattern;

    method new($pattern) {
        self.bless(:$pattern)
    }

    method destroy() {
        cairo_pattern_destroy($!pattern);
    }
}

class Cairo::Context {
    sub cairo_create(cairo_surface_t $surface)
        returns cairo_t
        is native('libcairo.so.2')
        {*}

    sub cairo_push_group(cairo_t $ctx)
        is native('libcairo.so.2')
        {*}

    sub cairo_pop_group(cairo_t $ctx)
        returns cairo_pattern_t
        is native('libcairo.so.2')
        {*}

    sub cairo_pop_group_to_source(cairo_t $ctx)
        is native('libcairo.so.2')
        {*}


    sub cairo_set_source_rgb(cairo_t $context, num $r, num $g, num $b)
        is native('libcairo.so.2')
        {*}

    sub cairo_set_source_rgba(cairo_t $context, num $r, num $g, num $b, num $a)
        is native('libcairo.so.2')
        {*}

    sub cairo_fill(cairo_t $ctx)
        is native('libcairo.so.2')
        {*}


    has cairo_t $!context;

    multi method new(cairo_t $context) {
        self.bless(:$context);
    }

    multi method new(Cairo::Surface $surface) {
        my $context = cairo_create($surface.surface);
        self.bless(:$context);
    }

    submethod BUILD(:$!context) { }

    method push_group() {
        cairo_push_group($!context);
    }

    method pop_group() returns Cairo::Pattern {
        Cairo::Pattern.new(cairo_pop_group($!context));
    }

    method pop_group_to_source() {
        cairo_pop_group_to_source($!context);
    }

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

    method fill {
        cairo_fill($!context)
    }
}
