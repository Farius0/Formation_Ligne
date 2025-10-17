from kivy.app import App
from kivy.properties import ObjectProperty

# from canvas_ex import *
from nav_screen_manager import NavScreenManager

class MyScreenManager(NavScreenManager):
    pass

class LeLabApp(App):
    manager = ObjectProperty(None)

    def build(self):
        self.manager = MyScreenManager()
        return self.manager
        # return CanvasEx7()

LeLabApp().run()