from kivy.lang import Builder
from kivy.uix.gridlayout import GridLayout
from kivy.properties import StringProperty, BooleanProperty

Builder.load_file("widget_ex.kv")

# class ImagesEx(GridLayout):
#     pass

class WidgetsEx(GridLayout):
    my_text = StringProperty("Hi")
    i = StringProperty("1")
    is_count = BooleanProperty(False)
    # slider_value_txt = StringProperty("")
    text_input = StringProperty("Here we go")
    def click_button(self):
        print("Click")
        if self.is_count:
            self.i = str(int(self.i) + 1)
        # self.my_text = "Bye"
    def toggle_button_state(self, widget):
        print("toggle state: " + widget.state)
        if widget.state == "normal":
            widget.text = "OFF"
            self.is_count = False
        else:
            widget.text = "ON"
            self.is_count = True
    # def on_switch_active(self, widget):
        # widget.active = self.is_count
        # print(widget.active)
    # def on_slider_value(self, widget):
    #     self.slider_value_txt = str(int(widget.value))
    #     print("Slider Value: ", self.slider_value_txt)
    def on_text_validate(self, widget):
        self.text_input = widget.text
