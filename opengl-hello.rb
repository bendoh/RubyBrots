require 'opengl'
require 'glu'
require 'glut'
include Gl,Glu,Glut

display = Proc.new do
  glClear(GL_COLOR_BUFFER_BIT)

  glColor(1.0, 1.0, 1.0)
  glBegin(GL_POINTS)
  glVertex(0.25, 0.25, 0.0)
  glVertex(0.75, 0.25, 0.0)
  glVertex(0.75, 0.75, 0.0)
  glVertex(0.25, 0.75, 0.0)
  glEnd()

  glutSwapBuffers()
end

def init
  glClearColor(0.0, 0.0, 0.0, 0.0)

  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glOrtho(0.0, 1.0, 0.0, 1.0, -1.0, 1.0)
end

keyboard = Proc.new do |key, x, y|
  case (key)
    when ?\e
    exit(0);
  end
end

glutInit
glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)
glutInitWindowSize(500, 500)
glutInitWindowPosition(100, 100)
glutCreateWindow("hello")
init()
glutDisplayFunc(display)
glutKeyboardFunc(keyboard)
glutMainLoop()
