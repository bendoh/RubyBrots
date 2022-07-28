require 'opengl'
require 'glu'
require 'glut'
include Gl,Glu,Glut

require 'set'

$limit = 20.0
$threshold = 1000
$width = 100.0
$height = 100.0

$offsetX = 0.5
$offsetY = 0
$scale = 0.03

$center = (0 + 0i)

colors = ['blue', 'green', 'red', 'orange']
 
def test_mandelbrot(c, zPrev = 0, n = 0, vals = Set[])
  mag = zPrev.abs
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

def draw
  for x in (0..$width)
    for y in (0..$height)
      coord = Complex(
        (x - ($width / 2) - $center.real) * $scale - $offsetX,
        (y - ($height / 2) - $center.imaginary) * $scale
      )
      result = test_mandelbrot coord

      if result > 0
        r = g = b = result / $limit
      else
        r = b = 0
        g = -result / $limit
      end

      glColor3f(r, g, b)

      sx = (Float x) / $width * 2.0 - 1.0
      sy = (Float y) / $height * 2.0 - 1.0

      puts "mandelbrot(#{coord} (#{sx},#{sy})) = #{result} (color='[#{r}, #{g}, #{b}]')"

      glBegin(GL_POINTS)
      glVertex2f(sx, sy)
      glEnd()
    end
  end
end

display = Proc.new do
  glClear(GL_COLOR_BUFFER_BIT)

  draw

  glutSwapBuffers()
end

def init
  glClearColor(0.0, 0.0, 0.0, 0.0)

  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
end

keyboard = Proc.new do |key, x, y|
  case (key)
    when ?\e
    exit(0);
  end
end

glutInit
glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
glutInitWindowSize($width, $height)
glutInitWindowPosition(100, 100)
glutCreateWindow("Fruby")
init()
glutDisplayFunc(display)
glutKeyboardFunc(keyboard)
glutMainLoop()

