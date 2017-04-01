module simpleui.window;
import std.string;
import xcb.xcb;

class Window {
    uint id;
    xcb_connection_t *c;
    int screen_nbr;

    private string title;

    private xcb_screen_t* getScreen() {
        xcb_screen_iterator_t iter;

        /* Get the screen #screen_nbr */
        iter = xcb_setup_roots_iterator (xcb_get_setup (c));
        for (; iter.rem; --screen_nbr, xcb_screen_next (&iter)) {
            if (screen_nbr == 0) {
                return iter.data;
            }
        }

        return null;
    }

    this(ushort width, ushort height, string title) {
        /* Open the connection to the X server. Use the DISPLAY environment variable */
        c = xcb_connect (null, &screen_nbr);

        this.id = xcb_generate_id(c);
        xcb_screen_t* screen = this.getScreen();

        // Create black foreground context
        uint mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
        uint[2] values = [screen.black_pixel, XCB_EVENT_MASK_EXPOSURE];

        xcb_create_window (c,
            XCB_COPY_FROM_PARENT,
            id,
            screen.root,
            0, 0,
            width, height,
            10,
            XCB_WINDOW_CLASS_INPUT_OUTPUT,
            screen.root_visual,          
            mask, &values[0]);

        xcb_map_window (c, id);

        // Create background
        mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
        values[0] = screen.white_pixel;
        values[1] = 0;
        uint foreground = xcb_generate_id(c);
        xcb_create_gc(c, foreground, id, mask, values.ptr);

        xcb_rectangle_t rectangle = {150, 150, 100, 100};
        xcb_poly_rectangle(c, id, foreground, 1u, &rectangle);

        this.setTitle(title);

        xcb_flush(c);

    }

    void setTitle(string title) {
        xcb_change_property(c,
                XCB_PROP_MODE_REPLACE,
                id,
                XCB_ATOM_WM_NAME,
                XCB_ATOM_STRING,
                8,
                cast(uint) title.length,
                title.toStringz);
        xcb_flush(c);
    }
}
