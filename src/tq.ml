(*
 * Copyright (C) 2015  Boucher, Antoni <bouanto@gmail.com>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *)

open TqBase
open TString

type color = TqBase.color = Black | Blue | Cyan | Default | Green | Magenta | Red | Yellow | White

type key_type = ArrowDown | ArrowLeft | ArrowRight | ArrowUp

type key =
    | Char of char
    | Key of key_type

type text_property =
    | TextBold
    | TextColor of color
    | TextItalic
    | TextNormal

let nop _ = ()

let on_keypress_function = ref (fun _ -> nop ())

let on_resize_function = ref (fun _ -> nop ())

let should_quit = ref false

let terminal_size = ref (0, 0)

let on_keypress func =
    on_keypress_function := func

let on_resize func =
    on_resize_function := func

let main_loop () =
    save_screen ();
    hide_cursor ();
    let rec loop () =
        let new_size = size () in
        if new_size <> !terminal_size then (
            terminal_size := new_size;
            !on_resize_function !terminal_size;
        );
        (match read_char () with
        | Some '\027' ->
                read_char ();
                (match read_char () with
                | Some 'A' -> !on_keypress_function (Key ArrowUp)
                | Some 'B' -> !on_keypress_function (Key ArrowDown)
                | Some 'C' -> !on_keypress_function (Key ArrowRight)
                | Some 'D' -> !on_keypress_function (Key ArrowLeft)
                | Some c -> !on_keypress_function (Char c)
                | None -> ()
                )
        | Some character -> !on_keypress_function (Char character)
        | None -> ()
        );
        if not !should_quit then
            loop ()
    in loop ();
    restore_screen ()

let set_property = function
    | TextBold -> set_bold ()
    | TextColor color -> set_color color
    | TextItalic -> set_italic ()
    | TextNormal -> ()

let set_properties = List.iter set_property

let shutdown () =
    should_quit := true

let unset_property = function
    | TextBold -> unset_bold ()
    | TextColor color -> set_color Default
    | TextItalic -> unset_italic ()
    | TextNormal -> ()

let unset_properties = List.iter unset_property

class virtual widget =
    object (self)
        val mutable on_keypress_function = fun _ -> false
        val mutable parent = (None : widget option)
        val mutable position = (0, 0)
        val mutable size = (0, 0)
        val mutable window = (None : window option)

        method virtual best_size : size -> size

        method clear (column, row) (width, height) =
            let max_row = row + height in
            let line = String.make width ' ' in
            let rec clear_line row =
                show_at line (column, row);
                if row < max_row then
                    clear_line (row + 1)
            in clear_line row

        method keypress =
            self#on_keypress_function

        method on_keypress keypress_function =
            on_keypress_function <- keypress_function

        method on_keypress_function = on_keypress_function

        method parent = parent

        method redraw =
            self#show position size

        method request_focus =
            match window with
            | Some window -> window#ask_focus (self :> widget)
            | None -> ()

        method set_parent new_parent =
            parent <- Some new_parent

        method set_window new_window =
            window <- Some new_window;
            self#request_focus

        method show new_position new_size =
            position <- new_position;
            size <- new_size;
            self#show_part 0 position size

        method virtual show_part : int -> position -> size -> unit

        method show_within ((column, row : position) as position) ((width, height : size) as size) content =
            self#clear position size;
            let lines = split content '\n' in
            let cut_line str = String.sub str 0 (min width (String.length str)) in
            let lines = List.map cut_line lines in
            let rec show_within row = function
                | [] -> ()
                | line :: rest ->
                        show_at line (column, row);
                        show_within (row + 1) rest
            in show_within row lines
    end

and window widget =
    object (self)
        val mutable focused_widget = None

        initializer
            on_resize (self#show (1, 1));
            on_keypress self#keypress;
            widget#set_window (self :> window)

        method ask_focus : widget -> unit = fun widget ->
            focused_widget <- Some (widget :> widget)

        method private keypress key =
            let rec keypress' = function
                | Some widget ->
                    if not (widget#keypress key)
                        then keypress' widget#parent
                | None -> ()
            in keypress' focused_widget

        method show position size =
            clear_screen ();
            set_cursor (1, 1);
            widget#show position size
    end

class virtual container =
    object (self)
        inherit widget

        val mutable children = [| |]

        method add : widget -> unit = fun widget ->
            widget#set_parent (self :> widget);
            children <- Array.append children [| (widget :> widget) |]

        method request_focus =
            match window with
            | Some window -> Array.iter (fun widget ->
                    window#ask_focus (widget :> widget)
            ) children
            | None -> ()
    end

class label ?(properties = []) text =
    object (self)
        inherit widget as super

        method best_size max_size =
            (String.length text, 1)

        method private compute_size (max_width, max_height) =
            let lines = split text '\n' in
            let line_lengths = List.map String.length lines in
            let width = min max_width (TList.max line_lengths) in
            let count_function length = int_of_float (ceil (float length /. float max_width)) in
            let line_counts = List.map count_function line_lengths in
            let height = min max_height (TList.sum line_counts) in
            (width, height)

        method show_part drop position ((width, _) as size) =
            if drop == 0 then (
                set_properties properties;
                let text_to_show =
                    let widget_width = min width (String.length text) in
                    String.sub text 0 widget_width
                in
                super#show_within position size text_to_show;
                unset_properties properties
            )
    end

class scrollbar ?(horizontal = true) ?(vertical = true) widget =
    object (self)
        inherit container

        val mutable max_value = 0
        val mutable value = 0

        initializer
            self#add (widget :> widget);
            self#on_keypress self#handle_arrow_keys

        method private handle_arrow_keys = function
            | Key ArrowUp ->
                    if value > 0 then (
                        value <- value - 1;
                        self#redraw;
                    );
                    true
            | Key ArrowDown ->
                    if value < max_value then (
                        value <- value + 1;
                        self#redraw;
                    );
                    true
            | _ -> false

        method best_size max_size =
            let (width, height) as size =
                if Array.length children > 0
                    then widget#best_size max_size
                    else (0, 0)
            in
            max_value <- height - 1;
            size

        method show_part drop position size =
            self#best_size size;
            if Array.length children > 0 then
                widget#show_part (drop + value) position size
    end

class textarea ?(properties = []) text =
    object (self)
        inherit widget as super

        method best_size max_size =
            self#compute_size max_size

        method private compute_size (max_width, max_height) =
            let lines = split text '\n' in
            let line_lengths = List.map String.length lines in
            let width = min max_width (TList.max line_lengths) in
            let count_function length = int_of_float (ceil (float length /. float max_width)) in
            let line_counts = List.map count_function line_lengths in
            let height = min max_height (TList.sum line_counts) in
            (width, height)

        method show_part drop position ((width, _) as size) =
            set_properties properties;
            let text_to_show = insert_every text width "\n" in
            super#show_within position size text_to_show;
            unset_properties properties
    end

class vbox =
    object (self)
        inherit container

        method best_size ((max_width, max_height) as max_size) =
            let best_sizes = Array.map (fun obj -> obj#best_size max_size) children in
            let best_widths = Array.map fst best_sizes in
            let best_width = TArray.max best_widths in
            let width = min max_width best_width in
            let best_heights = Array.map snd best_sizes in
            let best_height = TArray.sum best_heights in
            let height = min max_height best_height in
            (width, height)

        method show_part drop (column, row) (width, height) =
            let index = drop in
            let last_row = row + height - 1 in
            let rec show row index =
                if row > last_row || index >= Array.length children
                    then ()
                    else
                        let widget = children.(index) in
                        let max_height = last_row - row + 1 in
                        let (_, widget_best_height) = widget#best_size (width, max_height) in
                        let widget_height = min max_height widget_best_height in
                        widget#show (column, row) (width, widget_height);
                        show (row + widget_height) (index + 1)
            in show row index
    end
