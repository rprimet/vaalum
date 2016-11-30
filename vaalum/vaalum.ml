(* 
 * Copyright (C) 2016 Romain Primet
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the BSD license.  See the COPYING file for details.
 *)
open Lwt;;

let step = 400
let vol_delta = ref 0

type request_token = Req
let req_queue, req_pusher = Lwt_stream.create_bounded 1

(* map a sequence of button turn events to a sequence of volume inc/dec *)
let map_deltas evs = 
  let open Evdev in
  Lwt_stream.filter_map (fun evt ->
      match (evt.evtype, evt.code) with
      | (Rel, Dial) -> Some (step * evt.value)
      | _ -> None) evs

(* accumulate deltas, generate volume change events *)
let handle_delta ds = 
  Lwt_stream.iter (fun delta -> 
      vol_delta := !vol_delta + delta;
      if (req_pusher#count) < (req_pusher#size) then
        req_pusher#push Req |> ignore
      else
        () (* skip event -- there is already a vol change event waiting *)
    ) ds

let host = match Array.to_list Sys.argv with
  | [_; host] -> host
  | _ -> prerr_endline (Printf.sprintf "Usage: %s <host>\n" Sys.argv.(0)); exit 1

let get_vol () = Spotify.get_vol host

let set_vol = Spotify.set_vol host

let fetch_and_set_vol req =
  catch (fun () ->
    get_vol () >>= (fun v ->
        let new_vol = v + !vol_delta in
        vol_delta := 0;
        set_vol new_vol 
    )) 
  (fun ex -> vol_delta := 0; prerr_endline (Printexc.to_string ex); return ())

(**
 * Read the standard input for knob turn event messages
 * and send corresponding volume controls to spotify-connect-web
*)
let run () =
  let _ = Lwt_stream.iter_s fetch_and_set_vol req_queue in
  let ev_stream = Lwt_stream.map Evdev.parse (Lwt_io.read_lines Lwt_io.stdin) in
  let delta_stream = map_deltas ev_stream in
  handle_delta delta_stream

let () =  Lwt_main.run (run ())

