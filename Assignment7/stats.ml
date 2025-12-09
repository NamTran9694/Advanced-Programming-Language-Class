(*  Mean  *)

let mean lst =
  match lst with
  | [] -> failwith "mean: empty list"
  | _ ->
      let sum = List.fold_left ( + ) 0 lst in
      float_of_int sum /. float_of_int (List.length lst)

(*  Helper: nth element of a list  *)

let rec nth lst i =
  match lst, i with
  | [], _ -> failwith "nth: index out of bounds"
  | x :: _, 0 -> x
  | _ :: xs, n when n > 0 -> nth xs (n - 1)
  | _ -> failwith "nth: negative index"

(*  Median  *)

let median lst =
  match lst with
  | [] -> failwith "median: empty list"
  | _ ->
      let sorted = List.sort compare lst in
      let n = List.length sorted in
      if n mod 2 = 1 then
        (* odd length *)
        float_of_int (nth sorted (n / 2))
      else
        (* even length: average of middle two *)
        let a = nth sorted (n / 2 - 1) in
        let b = nth sorted (n / 2) in
        (float_of_int (a + b)) /. 2.0

(*  Group consecutive equal elements into (value, count) list  *)

let group_counts sorted =
  let rec aux current_val current_count acc lst =
    match lst with
    | [] ->
        (* push the last run *)
        (current_val, current_count) :: acc
    | x :: xs ->
        if x = current_val then
          aux current_val (current_count + 1) acc xs
        else
          aux x 1 ((current_val, current_count) :: acc) xs
  in
  match sorted with
  | [] -> []
  | x :: xs -> List.rev (aux x 1 [] xs)

(*  Mode(s): returns list of most frequent values  *)

let modes lst =
  match lst with
  | [] -> failwith "modes: empty list"
  | _ ->
      let sorted = List.sort compare lst in
      let counts = group_counts sorted in
      (* find max frequency *)
      let max_count =
        List.fold_left (fun acc (_, c) -> max acc c) 0 counts
      in
      (* collect all values with max_count *)
      List.fold_right
        (fun (v, c) acc ->
          if c = max_count then v :: acc else acc)
        counts
        []

(*  Converting command-line arguments to int list  *)

let int_list_of_argv () =
  let rec build i acc =
    if i >= Array.length Sys.argv then
      List.rev acc
    else
      let n = int_of_string Sys.argv.(i) in
      build (i + 1) (n :: acc)
  in
  build 1 []  (* skip Sys.argv.(0) = program name *)

(*  Main  *)

let () =
  let data = int_list_of_argv () in
  match data with
  | [] ->
      prerr_endline "Usage: stats_ml num1 num2 ...";
      exit 1
  | _ ->
      let m_mean = mean data in
      let m_median = median data in
      let m_modes = modes data in
      Printf.printf "Number of elements: %d\n" (List.length data);
      Printf.printf "Mean:   %.2f\n" m_mean;
      Printf.printf "Median: %.2f\n" m_median;
      Printf.printf "Mode(s): ";
      List.iter (fun v -> Printf.printf "%d " v) m_modes;
      Printf.printf "\n"
