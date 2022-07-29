require 'ruby2d'
require 'benchmark'
require 'set'

$limit = 20.0
$threshold = 1000
$width = 200
$height = 150

$offsetX = 0.5
$offsetY = 0
$scale = 0.015

# Set the window size
set width: $width, height: $height, title: "Mandelbruby"

center = (0 + 0i)

colors = ['blue', 'green', 'red', 'orange']
 
def test_mandelbrot(c, zPrev = 0, n = 0, vals = Set[])
  mag = zPrev.abs2
#  puts "magnitude(#{zPrev}) = #{mag}; vals=#{vals}"

  if mag > $threshold
    # How many iterations did it take to exceed the threshold?
    return Float n
  elsif n > $limit
    # Here we'll return how many values it bounced between as a
    # negative integer
    return -(vals.size)
  end

  zNext = zPrev ** 2 + c
  test_mandelbrot(c, zNext, n + 1, vals << zPrev)
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
