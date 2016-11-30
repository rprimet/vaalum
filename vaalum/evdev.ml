(* 
 * Copyright (C) 2016 Romain Primet
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the BSD license.  See the COPYING file for details.
 *)
type evtype = Key | Rel | Sync | Other of int
type code = Dial | Btn_0 | Other of int

type timestamp = { sec: nativeint; usec: int }
type event = { time: timestamp; evtype: evtype; code: code; value: int }

let evtype_of_int = function
  | 0 -> Sync
  | 1 -> Key
  | 2 -> Rel
  | i -> Other i

let code_of_int = function
  | 7 -> Dial
  | 256 -> Btn_0
  | i -> Other i

let parse_ts s =
  let sl = String.split_on_char '.' s in
  match sl with
  | [sec; usec] -> {sec = Nativeint.of_string sec; usec = int_of_string usec}
  | _ -> raise (Failure "parse_ts")

let parse s = 
  let sl = String.split_on_char ' ' s in
  match sl with
  | [ts; typeid; code; value] ->
    { time = parse_ts ts; evtype = evtype_of_int (int_of_string typeid); code = code_of_int (int_of_string code); value = int_of_string value }
  | _ -> raise (Failure "parse")


