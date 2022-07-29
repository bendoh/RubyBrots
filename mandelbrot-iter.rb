require 'ruby2d'
require 'benchmark'
require 'set'

$limit = 15
$threshold = 100
$width = 100
$height = 80

$offsetX = 0.5
$offsetY = 0
$scale = 0.015

# Set the window size
set width: $width, height: $height, title: "Mandelbruby"

center = (0 + 0i)

colors = ['blue', 'green', 'red', 'orange']
 
def test_mandelbrot(c)
  z = 0
  for n in (0..$limit)
    z = z ** 2 + c

    if z.abs > $threshold
      return $limit
    end
  end

  return -1
end

puts Benchmark.measure {
  for x in (0..$width)
    for y in (0..$height)
      coord = Complex((x - ($width / 2.0) - center.real) * $scale - $offsetX, (y - ($height / 2.0) - center.imaginary) * $scale)
      result = test_mandelbrot coord

      if result > 0
        color = [result / $limit, result / $limit, result / $limit, 1]
      else
        color = [0, -result / $limit, 0, 1]
      end

      # puts "mandelbrot(#{coord} (#{x}x#{y})) = #{result} #{color}"
      Square.new(size: 1, x: x, y: y, color: color)
    end
  end
}

show
