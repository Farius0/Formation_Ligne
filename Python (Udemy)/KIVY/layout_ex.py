from kivy.lang import Builder
from kivy.metrics import dp
from kivy.uix.button import Button
from kivy.uix.widget import Widget
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.scrollview import ScrollView
from kivy.uix.pagelayout import PageLayout
from kivy.uix.stacklayout import StackLayout
from kivy.uix.anchorlayout import AnchorLayout

Builder.load_file("layout_ex.kv")

class PageLayoutEx(PageLayout):
    pass

class ScrollViewEX(ScrollView):
    pass

class StackLayoutEx(StackLayout):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        for i in range(100):
            # b = Button(text=f"{i}", size_hint=(.25,.25))
            b = Button(text=f"{i+1}", size_hint=(None,None), size=(dp(50), dp(50)))
            self.add_widget(b)

class GridLayoutEx(GridLayout):
    pass

class AnchorLayoutEx(AnchorLayout):
    pass

class BoxLayoutEx(BoxLayout):
    pass
"""  
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.orientation = "vertical"

        b1 = Button(text="A")
        b2 = Button(text="B")
        b3 = Button(text="C")

        self.add_widget(b1)
        self.add_widget(b2)
        self.add_widget(b3)
"""

class MainWidget(Widget):
    pass