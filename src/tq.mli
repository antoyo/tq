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

val on_resize : (size -> unit) -> unit

val main_loop : unit -> unit

val shutdown : unit -> unit

class virtual widget :
    object
        method virtual show : position -> size -> unit
    end

class label : ?properties: text_property list -> ?multiline: bool -> string ->
    object
        method show : position -> size -> unit
    end

class window : widget ->
    object
        method on_keypress : char -> unit
        method show : position -> size -> unit
    end
