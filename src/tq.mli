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

type color = TqBase.color = Black | Blue | Cyan | Default | Green | Magenta | Red | Yellow | White

type text_property =
    | TextBold
    | TextColor of color
    | TextItalic
    | TextNormal

val on_resize : (size -> unit) -> unit

val main_loop : unit -> unit

val shutdown : unit -> unit

class virtual widget :
    object
        val mutable window : window option

        method virtual best_size : size -> size
        method set_window : window -> unit
        method virtual show : position -> size -> unit
        method virtual show_part : int -> position -> size -> unit
        method show_within : position -> size -> string -> unit
    end

and window : #widget ->
    object
        method private keypress : char -> unit
        method on_keypress : (char -> unit) -> unit
        method show : position -> size -> unit
    end

class virtual container :
    object
        val mutable children : widget array

        method add : widget -> unit
        method virtual best_size : size -> size
        method set_window : window -> unit
        method virtual show : position -> size -> unit
        method virtual show_part : int -> position -> size -> unit
        method show_within : position -> size -> string -> unit
    end

class label : ?properties: text_property list -> ?multiline: bool -> string ->
    object
        method best_size : size -> size
        method set_window : window -> unit
        method show : position -> size -> unit
        method show_part : int -> position -> size -> unit
        method show_within : position -> size -> string -> unit
    end

class scrollbar : ?horizontal: bool -> ?vertical: bool -> #widget ->
    object
        val mutable value : int

        method add : widget -> unit
        method best_size : size -> size
        method set_window : window -> unit
        method show : position -> size -> unit
        method show_part : int -> position -> size -> unit
        method show_within : position -> size -> string -> unit
    end

class vbox :
    object
        method add : widget -> unit
        method best_size : size -> size
        method set_window : window -> unit
        method show : position -> size -> unit
        method show_part : int -> position -> size -> unit
        method show_within : position -> size -> string -> unit
    end
