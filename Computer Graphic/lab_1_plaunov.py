from pyglet.gl import *
import pyglet
import pyglet.window.key as key

flag = False
stack = []
color_binds = dict({key._1 : (1, 1, 1),
               key._2 : (1, 0, 0),
               key._3 : (0, 1, 0),
               key._4 : (0, 0, 1),
               key._5 : (0.5, 0, 0),
               key._6 : (0, 0.5, 0),
               key._7 : (0, 0, 0.5),
               key._8 : (0.75, 0, 0),
               key._9 : (0, 0.75, 0),
               key._0 : (0, 0, 0.75)})
current_color = (1, 1, 1)
line_width = 1

def main():
    # Direct OpenGL commands to this window.
    window = pyglet.window.Window(resizable=True)
    window.maximize()
    print(window)
    @window.event
    def on_close():
        pyglet.app.exit()
        exit(0)
        return pyglet.event.EVENT_HANDLED
    @window.event
    def on_mouse_drag(x, y, dx, dy, button, modifier):
        global stack, flag
        if button & pyglet.window.mouse.LEFT:
            stack.append((x, y, current_color, line_width))
    @window.event
    def on_key_press(symbol, modifier):
        global current_color, color_binds, line_width
        if symbol in color_binds:
            current_color = color_binds[symbol]
            return
        if symbol == key.MINUS and line_width > 1:
            line_width -= 0.7
        elif symbol == key.EQUAL:
            line_width += 0.7
    @window.event
    def on_mouse_release(x, y, button, modifier):
        global stack
        if button == pyglet.window.mouse.LEFT and stack[-1]:
            stack.append(False)
    @window.event
    def on_draw():
        global stack, current_color, line_width
        glClear(GL_COLOR_BUFFER_BIT)
        u = current_color
        if len(stack) > 1:
            for i in range(1, len(stack)):
                if (stack[i] == False or stack[i - 1] == False):
                    continue
                u = stack[i][2]
                glLineWidth(stack[i][3])
                glBegin(GL_LINES)
                glColor3f(u[0], u[1], u[2])
                glVertex2f(stack[i - 1][0], stack[i - 1][1])
                glColor3f(u[0], u[1], u[2])
                glVertex2f(stack[i][0], stack[i][1])
                glEnd()
    pyglet.app.run()

if __name__ == "__main__":
    main()