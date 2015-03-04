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

type text_property =
    | TextBold
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
    | TextNormal -> ()

let set_properties = List.iter set_property

let shutdown () =
    should_quit := true

let unset_property = function
    | TextBold -> unset_bold ()
    | TextNormal -> ()

let unset_properties = List.iter unset_property

class virtual widget =
    object (self)
        method virtual show : position -> size -> unit
    end

class label ?(properties = []) ?(multiline = false) text =
    object (self)
        inherit widget

        method show position size =
            set_properties properties;
            if multiline
                then show text
                else show (String.sub text 0 (fst size));
            unset_properties properties
    end

class window widget =
    object (self)
        inherit widget

        initializer
            on_resize (self#show (1, 1));
            on_keypress self#on_keypress

        method on_keypress character =
            match character with
            | 'q' -> shutdown ()
            | _ -> ()

        method show position size =
            clear_screen ();
            set_cursor (1, 1);
            widget#show position size
    end
