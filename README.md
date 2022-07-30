# RubyBrots

Messing around with some fractals using ruby-opengl and ruby-glfw wrappers for
graphics and windowing.

Nothing groundbreaking here: Just a first-time experimentation with fractals as
well as shaders in GLSL and ruby in general.

**THIS IS JUST FOR FUN**

Feel free to use this as an example for quick windowed apps and a simple two-D
renderer using openGL in ruby and GLFW to get a window context. The author of
ruby-glfw gets most of the credit here.

This software is poorly structured and not intended for any sort of production
environment. Its purpose is to demonstrate some simple graphical stuff using
ruby.

Uses GLFW library and wrappers from https://github.com/ForeverZer0/glfw

# Requirements

Requires Ruby 3.1+ (possibly earlier: untested) as well as these gems:

- opengl (0.10.x+)

- glfw (3.3.x+)

# Usage

```sh

# A basic MandelBrot display with trippy rotating colors but no perturbation
# Meaning it gets to a zoom of about e6 before pixelating out
% ruby glfw-mandelbrot.rb

# A mandelbrot viewer with one level of perturbation which allows for much
# deeper (but ever slower) zooms: this is buggy and if the zoom center is not
# part of the set, color glitches occur (stolen idea); as iteration count gets
# toward 500, this gets slower and slower to render
% ruby ruby-mandelbrot.rb

# A julia set renderer
% ruby glfw-julia.rb

```



