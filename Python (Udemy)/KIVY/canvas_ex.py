from kivy.lang import Builder
from kivy.uix.widget import Widget
from kivy.graphics import Line, Color, Rectangle, Ellipse
from kivy.metrics import dp
from kivy.properties import Clock
from kivy.uix.boxlayout import BoxLayout

Builder.load_file("canvas_ex.kv")

class CanvasEx(Widget):
    pass

class CanvasEx2(Widget):
    pass

class CanvasEx3(Widget):
    pass

class CanvasEx4(Widget):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        with self.canvas:
            Color(1, 1, 1, 1)
            Line(circle=(100, 100, 50), width=2)
            Line(circle=(300, 100, 50), width=2)
            Line(rectangle=(450, 100, 100, 100), width=2)
            Line(points=(100, 100, 200, 200, 300, 100), width=2)
            Color(0, 1, 1, 1)
            self.rect = Rectangle(pos=(450, 450), width=2)

    def click_to_move(self):
        x, y = self.rect.pos
        w, h = self.rect.size
        incr = dp(10)

        diff_right = self.width - (x + w)

        if diff_right >= incr :
            x += dp(10)
        else:
            x += diff_right

        self.rect.pos = (x, y)

class CanvasEx5(Widget):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.ball_size = dp(50)
        self.vx = dp(4)
        self.vy = dp(3)
        with self.canvas:
            Color(1, 0, 0, 1)
            self.ball = Ellipse(pos=(100, 100), size=(self.ball_size, self.ball_size))
        Clock.schedule_interval(self.update, 1/60)

    def on_size(self, *args):
        self.ball.pos = (self.width - self.ball_size) // 2, (self.height - self.ball_size) // 2

    def update(self, dt):
        x, y = self.ball.pos
        w, h = self.ball.size

        x, self.vx = self.update_one_pos(x, self.vx, w, self.width)
        y, self.vy = self.update_one_pos(y, self.vy, h, self.height)

        # if self.vx >= 0:
        #     diff_right = self.width - (x + w)
        #     if diff_right >= self.vx:
        #         x += self.vx
        #     else:
        #         x += diff_right
        #         self.vx = -self.vx
        # else:
        #     if x >= self.vx:
        #         x += self.vx
        #     else:
        #         x -=x
        #         self.vx = -self.vx
        #
        # if self.vy >= 0:
        #     diff_bottom = self.height - (y + h)
        #     if diff_bottom >= self.vy:
        #         y += self.vy
        #     else:
        #         y += diff_bottom
        #         self.vy = -self.vy
        # else:
        #     if y >= self.vy:
        #         y += self.vy
        #     else:
        #         y -= y
        #         self.vy = -self.vy

        self.ball.pos = (x, y)

    @staticmethod
    def update_one_pos(pos, vit, obj_size, screen_size):
        if vit >= 0:
            diff = screen_size - (pos + obj_size)
            if diff >= vit:
                pos += vit
            else:
                pos += diff
                vit = -vit
        else:
            if pos >= vit:
                pos += vit
            else:
                pos -= pos
                vit = -vit

        # print(pos, vit)

        return pos, vit

class CanvasEx6(Widget):
    pass

class CanvasEx7(BoxLayout):
    pass