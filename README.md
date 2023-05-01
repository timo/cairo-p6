Cairo 2D Graphics library binding for Raku
==========================================

Synopsis
--------

```raku
use Cairo;
given Cairo::Image.create(Cairo::FORMAT_ARGB32, 128, 128) {
    given Cairo::Context.new($_) {
        .rgb(0, 0.7, 0.9);
        .rectangle(10, 10, 50, 50);
        .fill :preserve; .rgb(1, 1, 1);
        .stroke
    };
    .write_png("foobar.png")
}
```


Native Cairo library
--------------

In order to use this module, native `Cairo` library is needed. See instructions at https://cairographics.org/download/.

### Examples

doc/screenshot/arc-negative.png
![arc-negative.png](doc/screenshot/arc-negative.png)

doc/screenshot/arc.png
![arc.png](doc/screenshot/arc.png)

doc/screenshot/clip-image.png
![clip-image.png](doc/screenshot/clip-image.png)

doc/screenshot/clip.png
![clip.png](doc/screenshot/clip.png)

doc/screenshot/curve-rectangle.png
![curve-rectangle.png](doc/screenshot/curve-rectangle.png)



doc/screenshot/curve_to.png
![curve_to.png](doc/screenshot/curve_to.png)

doc/screenshot/dash.png
![dash.png](doc/screenshot/dash.png)

doc/screenshot/fill-and-stroke.png
![fill-and-stroke.png](doc/screenshot/fill-and-stroke.png)

doc/screenshot/fill-style.png
![fill-style.png](doc/screenshot/fill-style.png)

doc/screenshot/gradient.png
![gradient.png](doc/screenshot/gradient.png)

doc/screenshot/image-pattern.png
![image-pattern.png](doc/screenshot/image-pattern.png)

doc/screenshot/image.png
![image.png](doc/screenshot/image.png)

doc/screenshot/multi-page-pdf.pdf
![multi-page-pdf.pdf](doc/screenshot/multi-page-pdf.pdf)

doc/screenshot/multi-segment-caps.png
![multi-segment-caps.png](doc/screenshot/multi-segment-caps.png)

doc/screenshot/rounded-rectangle.png
![rounded-rectangle.png](doc/screenshot/rounded-rectangle.png)

doc/screenshot/set-line-cap.png
![set-line-cap.png](doc/screenshot/set-line-cap.png)

doc/screenshot/set-line-join.png
![set-line-join.png](doc/screenshot/set-line-join.png)

doc/screenshot/svg-surface.svg
![svg-surface.svg](doc/screenshot/svg-surface.svg)

doc/screenshot/text-align-center.png
![text-align-center.png](doc/screenshot/text-align-center.png)

doc/screenshot/text-extents.png
![text-extents.png](doc/screenshot/text-extents.png)

doc/screenshot/text.png
![text.png](doc/screenshot/text.png)
