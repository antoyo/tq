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

type color = Black | Blue | Cyan | Green | Magenta | Red | Yellow | White

type size = int * int

val clear_screen : unit -> unit

val hide_cursor : unit -> unit

val read_char : unit -> char option

val restore_screen : unit -> unit

val save_screen : unit -> unit

val set_bold : unit -> unit

val set_cursor : int -> int -> unit

val set_color : color -> unit

val set_italic : unit -> unit

val show : string -> unit

val show_at : string -> int -> int -> unit

val show_cursor : unit -> unit

val size : unit -> size

val unset_bold : unit -> unit

val unset_italic : unit -> unit
