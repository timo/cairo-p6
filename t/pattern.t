use v6;
use Cairo;
use Test;

plan 7;

{
    my $pattern = Cairo::Pattern.create_rgb(.7, .5, .3);
    isa-ok $pattern, Cairo::Pattern::Solid;
}

{
    my $pattern = Cairo::Pattern.create_rgba(.7, .5, .3, .5);
    isa-ok $pattern, Cairo::Pattern::Solid;
}

{
    my $image = Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128);
    my $pattern = Cairo::Pattern.create_for_surface($image.surface);
    isa-ok $pattern, Cairo::Pattern::Surface;
}

{
    my $pattern = Cairo::Pattern.create_linear(0,0,170,120);
    isa-ok $pattern, Cairo::Pattern::Gradient::Linear;
    lives-ok {$pattern.add_color_stop_rgb(0.5, .8, .1, .1);}, 'linear color stop';
}

{
    my $pattern = Cairo::Pattern.create_radial(75,50,5,90,60,100);
    isa-ok $pattern, Cairo::Pattern::Gradient::Radial;
    lives-ok {$pattern.add_color_stop_rgb(0.5, .8, .1, .1);}, 'radial color stop';
}

done-testing;
