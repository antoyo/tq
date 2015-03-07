open Tq

let () =
    let vbox = new vbox in
    let label1 = new label ~properties: [TextBold] "Hello World!" in
    (*let label2 = new label ~multiline: true "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse vitae augue sed metus ullamcorper suscipit. Donec eget dapibus eros. Nunc consectetur ut turpis non convallis. Maecenas ac nisl tincidunt, dictum justo et, tincidunt augue. Quisque egestas sed lectus ac viverra. Cras dictum et nisl et imperdiet. Sed laoreet viverra porta. Pellentesque id sodales risus. Proin leo nibh, efficitur in dolor et, gravida hendrerit sapien. Phasellus cursus lectus augue, vitae convallis lectus pharetra vel. Etiam eros erat, maximus vitae mi quis, eleifend hendrerit magna. Vestibulum sit amet velit malesuada, egestas ante id, vestibulum massa. Suspendisse non odio volutpat dolor commodo facilisis non id erat. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tristique neque eget tortor elementum, vel molestie justo faucibus. Vestibulum eu dui non odio accumsan laoreet." in*)
    let label3 = new label "Hello World!" in
    let label4 = new label ~properties: [TextColor Red] "Hello World!" in
    let label5 = new label ~multiline: true ~properties: [TextItalic] "Hello World!" in
    vbox#add label1;
    (*vbox#add label2;*)
    vbox#add label3;
    vbox#add label4;
    vbox#add label5;
    for i = 0 to 40 do
        vbox#add label3
    done;
    let scrollbar = new scrollbar vbox in
    let window = new window scrollbar in
    window#on_keypress (fun character ->
        match character with
        | 'q' -> shutdown ()
        | _ -> ()
    );
    main_loop ()
