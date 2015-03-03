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

open Base

let nop () = ()

let on_keypress_function = ref (fun _ -> nop ())

let on_resize_function = ref (fun _ _ -> nop ())

let should_quit = ref false

let on_keypress func =
    on_keypress_function := func

let on_resize func =
    on_resize_function := func

let main_loop () =
    let (width, height) = size () in
    save_screen ();
    clear_screen ();
    !on_resize_function width height;
    let rec loop width height =
        let (new_width, new_height) = size () in
        if new_width <> width || height <> new_height then
            !on_resize_function width height;
        (match read_char () with
        | Some character -> !on_keypress_function character
        | None -> ()
        );
        if not !should_quit then
            loop new_width new_height
    in loop width height;
    restore_screen ()

let shutdown () =
    should_quit := true
