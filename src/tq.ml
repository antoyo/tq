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
        | Some character -> !on_keypress_function character
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
        method virtual best_size : size -> size

        method virtual show : position -> size -> unit

        method show_within (column, row : position) (width, height : size) content =
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

class virtual container =
    object (self)
        inherit widget

        val mutable children = [| |]

        method add : 'a. (#widget as 'a) -> unit = fun widget ->
            children <- Array.append children [| (widget :> widget) |]
    end

class label ?(properties = []) ?(multiline = false) text =
    object (self)
        inherit widget as super

        method best_size max_size =
            if multiline
                then self#compute_size max_size
                else (String.length text, 1)

        method private compute_size (max_width, max_height) =
            let lines = split text '\n' in
            let line_lengths = List.map String.length lines in
            let width = min max_width (TList.max line_lengths) in
            let count_function length = int_of_float (ceil (float length /. float max_width)) in
            let line_counts = List.map count_function line_lengths in
            let height = min max_height (TList.sum line_counts) in
            (width, height)

        method show position ((width, _) as size) =
            set_properties properties;
            let text_to_show =
                if multiline
                    then insert_every text width "\n"
                    else
                        let widget_width = min width (String.length text) in
                        String.sub text 0 widget_width
            in
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
            let best_height = TArray.max best_heights in
            let height = min max_height best_height in
            (width, height)

        method show (column, row) (width, height) =
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
            in show row 0
    end

class window widget =
    object (self)
        val mutable on_keypress_function = nop

        initializer
            on_resize (self#show (1, 1));
            on_keypress self#keypress

        method private keypress character =
            on_keypress_function character

        method on_keypress keypress_function =
            on_keypress_function <- keypress_function

        method show position size =
            clear_screen ();
            set_cursor (1, 1);
            (widget :> widget)#show position size
    end
