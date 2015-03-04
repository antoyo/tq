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

(** Returns a new string containing the [text] with the [sep] string inserted at every [every_index] characters. *)
val insert_every : string -> int -> string -> string

(** Returns a substring that contains the [n] leftmost characters of the string. *)
val left : string -> int -> string

(** Returns a string that contains [n] characters of the string, starting at the specified [position] index.
 *
 * If n is -1 (default), the function returns all characters that are available from the speficied [position].
 * *)
val mid : string -> ?n : int -> int -> string

(** Splits the string into substrings wherever [sep] occurs, and returns the list of those strings. *)
val split : string -> char -> string list
