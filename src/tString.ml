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

let left text n = String.sub text 0 n

let mid text ?(n = -1) position =
    let n =
        if n = -1
            then String.length text - position
            else n
    in String.sub text position n

let insert_every text every_index sep =
    let rec insert_every text =
        if String.length text > every_index
            then let next_strings = insert_every (mid text every_index) in
                 left text every_index :: next_strings
            else [text]
    in String.concat sep (insert_every text)

let split text sep =
    let rec split = function
        | "" -> []
        | text ->
                try
                    let delimiter_index = String.index text sep in
                    let start_index = delimiter_index + 1 in
                    let next_strings = split (String.sub text start_index (String.length text - start_index)) in
                    left text delimiter_index :: next_strings
                with Not_found ->
                    [text]
    in split text
