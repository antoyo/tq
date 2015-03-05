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

type color = Black | Blue | Cyan | Default | Green | Magenta | Red | Yellow | White

type position = int * int

type size = int * int

let () =
    let terminfo = Unix.tcgetattr Unix.stdin in
    let new_terminfo = {terminfo with Unix.c_isig = false; Unix.c_icanon = false; Unix.c_vmin = 0; Unix.c_vtime = 1; Unix.c_echo = false } in
    let reset_stdin () = Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH terminfo in at_exit reset_stdin;
    Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH new_terminfo

let string_of_color = function
    | Black -> "0"
    | Blue -> "4"
    | Cyan -> "6"
    | Default -> "9"
    | Green -> "2"
    | Magenta -> "5"
    | Red -> "1"
    | Yellow -> "3"
    | White -> "7"

let write code =
    let bytes = Bytes.of_string ("\027" ^ code) in
    let _ = Unix.write Unix.stdout bytes 0 (Bytes.length bytes) in
    ()

let clear_screen () = write "[2J" 

let hide_cursor () = write "[?25l"

let bytes = Bytes.create 1

let get_char () =
    let _ = Unix.read Unix.stdin bytes 0 1 in
    Bytes.get bytes 0

let read_char () =
    let count = Unix.read Unix.stdin bytes 0 1 in
    if count == 1
        then Some (Bytes.get bytes 0)
        else None

let restore_screen () = write "[?47l"

let save_screen () = write "[?47h"

let set_bold () = write "[1m"

let set_cursor (column, row) = write ("[" ^ string_of_int row ^ ";" ^ string_of_int column ^ "H")

let set_color color = write ("[3" ^ string_of_color color ^ "m")

let set_italic () = write "[3m"

let show str =
    let bytes = Bytes.of_string str in
    let _ = Unix.write Unix.stdout bytes 0 (Bytes.length bytes) in
    ()

let show_at str position =
    set_cursor position;
    show str

let show_cursor () = write "[?25h"

let unset_bold () = write "[21m"

let unset_italic () = write "[23m"

let digit_of_char character =
    Char.code character - Char.code '0'

let read_numbers () =
    let rec read_number number =
        match get_char () with
        | 't' | ';' -> number
        | character ->
                read_number (number * 10 + digit_of_char character)
    in
    let height = read_number 0 in
    let width = read_number 0 in
    (width, height)

let size () =
    write "[18t";
    let rec read () =
        flush stdout;
        if get_char () = ';' then (
            read_numbers ()
        )
        else
            read ()
    in
    let size = read () in
    flush_all ();
    size
