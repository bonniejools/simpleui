import std.stdio;
import xcb.xcb;

int main()
{
    xcb_connection_t     *c;
    xcb_screen_t         *screen;
    int                   screen_nbr;
    xcb_screen_iterator_t iter;

    /* Open the connection to the X server. Use the DISPLAY environment variable */
    c = xcb_connect (null, &screen_nbr);

    /* Get the screen #screen_nbr */
    iter = xcb_setup_roots_iterator (xcb_get_setup (c));
    for (; iter.rem; --screen_nbr, xcb_screen_next (&iter)) {
	if (screen_nbr == 0) {
	    screen = iter.data;
	    break;
	}
    }

    printf ("Informations of screen %ld:\n", screen.root);
    printf ("  width.........: %d\n", screen.width_in_pixels);
    printf ("  height........: %d\n", screen.height_in_pixels);
    printf ("  white pixel...: %ld\n", screen.white_pixel);
    printf ("  black pixel...: %ld\n", screen.black_pixel);

    uint window = xcb_generate_id(c);

    // Create black foreground context
    uint mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    uint[2] values = [screen.white_pixel, XCB_EVENT_MASK_EXPOSURE];

    xcb_create_window (c,              /* Connection          */
        XCB_COPY_FROM_PARENT,          /* depth (same as root)*/
        window,                        /* window Id           */
        screen.root,                   /* parent window       */
        0, 0,                          /* x, y                */
        300, 300,                      /* width, height       */
        10,                            /* border_width        */
        XCB_WINDOW_CLASS_INPUT_OUTPUT, /* class               */
        screen.root_visual,            /* visual              */
        mask, &values[0]);
        //0, null);

    xcb_map_window (c, window);
    xcb_flush(c);

    // Create background
    mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
    values[0] = screen.black_pixel;
    values[1] = 0;
    uint foreground = xcb_generate_id(c);
    xcb_create_gc(c, foreground, window, mask, values.ptr);

    xcb_rectangle_t rectangle = {0, 0, 300, 300};
    xcb_poly_rectangle(c, window, foreground, 1u, &rectangle);

    xcb_flush(c);

    readln();

    return 0;
}

