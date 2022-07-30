require 'glfw'
require_relative 'gl'
require_relative 'shader'

class RubyMandel < GLFW::Window

  include GL
  include Fiddle
  include GLFW

  def initialize(width, height, title)
    @maxScale = 1.5
    @scale = @maxScale
    set_num_iterations

    @offset = [-0.5, 0]
    @dragStart = [0, 0]

    @colorRotation = 0
    @rotationX = 0
    @rotationY = 0
    @xSpeed = 0.01
    @ySpeed = 0.01

    Window.default_hints
    Window.hint(HINT_CLIENT_API, API_OPENGL)
    Window.hint(HINT_OPENGL_PROFILE, PROFILE_OPENGL_CORE)
    Window.hint(HINT_CONTEXT_VERSION_MAJOR, 3)
    Window.hint(HINT_CONTEXT_VERSION_MINOR, 3)
    Window.hint(HINT_DOUBLEBUFFER, true)
    Window.hint(HINT_OPENGL_FORWARD_COMPAT, true)
    Window.hint(HINT_DECORATED, true)
    Window.hint(HINT_RESIZABLE, true)
    Window.hint(HINT_VISIBLE, false)

    super(width, height, title, vsync: true)

    self.icon = Image.new('glfw-icon.png')
    setup(width, height)

    # Tweak the position to force a redraw, which fixes a bug at least in MacOS
    # GLFW where the viewport starts at the bottom-left quadrant until a move occurs
    # https://stackoverflow.com/questions/43985162/opengl-or-glfw-renders-ok-only-when-moving-the-window
    position = self.position
    position.width = position.width + 1
    self.position = position
    puts "Window position: #{position.width} and #{position.height}"

    set_callbacks
  end

  def set_num_iterations
    maxIterations = 600;
    @numIterations = 25 + Math.log(1.5/@scale) * 15


    if @numIterations > maxIterations
      @numIterations = maxIterations
    end

    puts "# iterations: #{@numIterations}"
  end

  def set_callbacks
    # Update the viewport when the framebuffer size changes
    on_framebuffer_resize do |width, height|
      glViewport(0, 0, width, height)
    end

    # Cleanup when window is closing
    on_close do
      glDeleteProgram(@shader.id)
      glDeleteVertexArrays(1, [@vao].pack('L'))
      glDeleteBuffers(1, [@vbo].pack('L'))
    end

    on_scroll do |x, y|
      @scale *= (1 - (y/50))

      if @scale > @maxScale
        @scale = @maxScale
      end

      puts "Scale: #{y} #{@scale}"

      set_num_iterations
    end

    on_cursor_move do |x, y|
      if @dragging == 1
        unitX = @dragStart[0] / self.size.width * 2 - 1
        unitY = @dragStart[1] / self.size.height * 2 - 1

        @rotationX = unitX * 3.14
        @rotationY = unitY * 3.14

        @dragStart = [x, y]
      elsif (x >= 0 and x < self.size.width and y > 0 and y < self.size.height)
        @dragStart = [x, y]
      end
    end

    on_mouse_button do |button, action, modifiers|
      puts "I clicked: #{button}, #{action}, #{modifiers} at #{@dragStart[0]},#{@dragStart[1]}"
      if (button == 0)
        @dragging = action
      end

      if (button == 1 and action == 1)
        # In screen space; we clicked 0 .. width x 0 .. height
        # In unit space, -1 .. 1
        # In virtual space, it was (@offset + @unit) / @scale
        unitX = @dragStart[0] / self.size.width * 2 - 1
        unitY = @dragStart[1] / self.size.height * 2 - 1
        @xSpeed = unitX / 10
        @ySpeed = unitY / 10

      end
    end
  end

  def setup(width, height)
    make_current
    GL.import_functions

    create_shader
    create_vertex_array

    glViewport(0, 0, width, height)
    glClearColor(0.1, 0.1, 0.2, 1.0)
  end

  def create_shader

    vertex = <<-EOS
    #version 330 core
    layout (location = 0) in vec2 position;
      
    out vec2 xy;
    
    void main()
    {
        float x = position.x;
        float y = position.y;
        gl_Position = vec4(x, y, 0, 1.0);
        xy = vec2(x, y);
    }
    EOS

    # From https://www.shadertoy.com/view/ttVSDW
    fragment = <<-EOS
    #version 330 core
  
    in vec2 xy;

    uniform float rotation;
    uniform float scale;
    uniform vec2 offset;
    uniform float numIterations;

    out vec3 pixelColor;
    
    vec2 cmul(vec2 a, vec2 b) { return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }

    float julia(vec2 z0)
    {
      float limit = 4.0;

      float real = z0.x, imaginary = z0.y;

      float iteration;
      float r2, i2, rtemp, mag2;

      for (iteration = 0; iteration < numIterations && mag2 < limit; iteration++) {
        r2 = real * real;
        i2 = imaginary * imaginary;

        rtemp = real;
        real = r2 - i2 + offset.x;
        imaginary = 2.0 * rtemp * imaginary + offset.y;
        
        mag2 = r2 + i2;
      }

      if (mag2 < limit) {
        return -mag2;
      } else {
        return iteration;
      }
    }

    vec3 hsv2rgb(vec3 c)
    {
        vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
        vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
        return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    void main()
    {
        vec2 dc = xy * scale;
        float l = julia(dc);

        if (l < 0) {
          float closeness = -log2(l / 4);
          pixelColor = vec3(closeness, cos(1 / closeness), closeness);
        } else {
          float shade = l / numIterations;
          pixelColor = hsv2rgb(
            vec3(
              (sin(shade * 2 + rotation) + 1) / 2,
              1,
              1
            )
          );
        }
    } 
    EOS

    @shader = Shader.new(vertex, fragment)
    @shader.use
  end

  def get_vertices
    return [
      1, 1,
      1, -1,
      -1, 1,
      -1, -1,
    ]
  end

  def create_vertex_array
    vertices = get_vertices
    ptr = "\0" * SIZEOF_INT
    glGenVertexArrays(1, ptr)
    @vao = ptr.unpack1('L')

    glGenBuffers(1, ptr)
    @vbo = ptr.unpack1('L')

    glBindVertexArray(@vao)

    glBindBuffer(GL_ARRAY_BUFFER, @vbo)
    glBufferData(GL_ARRAY_BUFFER, vertices.size * SIZEOF_FLOAT, vertices.pack('f*'), GL_STATIC_DRAW)
    
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * SIZEOF_FLOAT, nil)
    glEnableVertexAttribArray(0)
  end

  def main
    show
    make_current

    until closing?
      render
      GLFW.poll_events

      @colorRotation += 0.03

      if @dragging != 1
        @rotationX += @xSpeed
        @rotationY += @ySpeed
      end

      @offset[0] = Math.sin(@rotationX) - 0.5
      @offset[1] = Math.cos(@rotationY)
      @shader.bindUniform1f("rotation", @colorRotation)
      @shader.bindUniform1f("scale", @scale)
      @shader.bindUniform2f("offset", @offset[0], @offset[1])
      @shader.bindUniform1f("numIterations", @numIterations)
    end
  end

  def render
    glClear(GL_COLOR_BUFFER_BIT)

    create_vertex_array
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

    swap_buffers
  end
end


GLFW.init

game = RubyMandel.new(512, 384, 'RubyMandel')
game.main

GLFW.terminate
