(* 
 * Copyright (C) 2016 Romain Primet
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the BSD license.  See the COPYING file for details.
 *)
open Lwt;;
open Cohttp;;
open Cohttp_lwt_unix;;

let clip min max v = 
  if v < min then min
  else if v > max then max
  else v

let clip_vol = clip 0 39320

let get_vol host = 
  let open Yojson.Basic.Util in
  Client.get (Uri.of_string (host ^ "/api/playback/volume")) >>= fun (resp, body) ->
  let status = resp |> Response.status in
  match status with
  | `OK -> body |> Cohttp_lwt_body.to_string >|= fun body ->
    let j = Yojson.Basic.from_string body in
    j |> member "volume" |> to_int 
  | _ -> fail (Failure (Code.string_of_status status))

let set_vol host v = 
  let vc = clip_vol v in
  let body = "value=" ^ (string_of_int vc) in
  let headers = ["Content-Length", string_of_int (String.length body);
                 "Content-Type", "application/x-www-form-urlencoded"] in
  Client.post (Uri.of_string (host ^ "/api/playback/volume")) ~headers: (Header.of_list headers) ~body: (`String body) >>= fun (resp, body) ->
  let status = resp |> Response.status in
  match status with
  | `OK | `No_content -> return ()
  | _ -> fail (Failure (Code.string_of_status status))


