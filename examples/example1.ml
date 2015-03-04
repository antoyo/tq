open Tq

(*let draw width height =
    set_cursor 0 0;
    show "Hello ";
    set_bold ();
    show "World!\n";
    unset_bold ();
    show "Hello ";
    set_italic ();
    show "World!\n";
    unset_italic ();
    show "Hello ";
    set_color Red;
    show "World!\n";
    set_color White;
    hide_cursor ();
    show_cursor ()*)

let () =
    (*let label = new label ~properties: [TextBold] "Hello World!" in*)
    let label = new label ~multiline: true "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse vitae augue sed metus ullamcorper suscipit. Donec eget dapibus eros. Nunc consectetur ut turpis non convallis. Maecenas ac nisl tincidunt, dictum justo et, tincidunt augue. Quisque egestas sed lectus ac viverra. Cras dictum et nisl et imperdiet. Sed laoreet viverra porta. Pellentesque id sodales risus. Proin leo nibh, efficitur in dolor et, gravida hendrerit sapien. Phasellus cursus lectus augue, vitae convallis lectus pharetra vel. Etiam eros erat, maximus vitae mi quis, eleifend hendrerit magna. Vestibulum sit amet velit malesuada, egestas ante id, vestibulum massa. Suspendisse non odio volutpat dolor commodo facilisis non id erat. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tristique neque eget tortor elementum, vel molestie justo faucibus. Vestibulum eu dui non odio accumsan laoreet." in
    let window = new window label in
    main_loop ()
