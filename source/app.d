import std.stdio;
import xcb.xcb;

import simpleui.window;

int main()
{
    auto w = new Window(600, 600, "Hello, world");
    readln();
    return 0;
}

