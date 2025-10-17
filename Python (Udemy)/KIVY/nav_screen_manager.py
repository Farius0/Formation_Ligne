from kivy.uix.screenmanager import ScreenManager

class NavScreenManager(ScreenManager):
    screen_stack = []

    def push_screen(self, screen_name):
        self.screen_stack.append(self.current)
        self.transition.direction = "left"
        self.current = screen_name

    def pop_screen(self):
        if len(self.screen_stack) != 0:
            screen_name = self.screen_stack.pop()
            self.transition.direction = "right"
            self.current = screen_name