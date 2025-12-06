(* Basic Financial Portfolio Manager in OCaml *)

(* 1. Portfolio Data Structure *)

type stock = {
  symbol : string;
  quantity : int;
  purchase_price : float;
  current_price : float;
}

(* A portfolio is simply a list of stocks *)
type portfolio = stock list

(* 2. Helper / Utility Functions *)

let stock_value (s : stock) : float =
  float_of_int s.quantity *. s.current_price

let stock_gain_loss (s : stock) : float =
  float_of_int s.quantity *. (s.current_price -. s.purchase_price)

(* Recursive search for a stock by symbol, returning an option *)
let rec find_stock (sym : string) (p : portfolio) : stock option =
  match p with
  | [] -> None
  | s :: rest ->
      if String.uppercase_ascii s.symbol = String.uppercase_ascii sym then
        Some s
      else
        find_stock sym rest

(* 2. Basic Functionality *)

(* Add a stock:
   - If the symbol already exists, replace it with the new one.
   - Otherwise, add it to the front of the list. *)
let rec add_stock (new_stock : stock) (p : portfolio) : portfolio =
  match p with
  | [] -> [ new_stock ]
  | s :: rest ->
      if String.uppercase_ascii s.symbol = String.uppercase_ascii new_stock.symbol
      then new_stock :: rest
      else s :: add_stock new_stock rest

(* Remove a stock by symbol (if not found, portfolio stays unchanged) *)
let rec remove_stock (sym : string) (p : portfolio) : portfolio =
  match p with
  | [] -> []
  | s :: rest ->
      if String.uppercase_ascii s.symbol = String.uppercase_ascii sym
      then rest
      else s :: remove_stock sym rest

(* Update current price of a given symbol.
   If the stock is not found, portfolio is returned unchanged. *)
let rec update_price (sym : string) (new_price : float) (p : portfolio) : portfolio =
  match p with
  | [] -> []
  | s :: rest ->
      if String.uppercase_ascii s.symbol = String.uppercase_ascii sym
      then { s with current_price = new_price } :: rest
      else s :: update_price sym new_price rest

(* Recursive Calculations *)

let rec total_portfolio_value (p : portfolio) : float =
  match p with
  | [] -> 0.0
  | s :: rest -> stock_value s +. total_portfolio_value rest

let rec overall_gain_loss (p : portfolio) : float =
  match p with
  | [] -> 0.0
  | s :: rest -> stock_gain_loss s +. overall_gain_loss rest

(* 3. String / Display Functions *)

let string_of_float2 (x : float) : string =
  Printf.sprintf "%.2f" x

let string_of_stock (s : stock) : string =
  let value = stock_value s in
  let gain = stock_gain_loss s in
  Printf.sprintf
    "Symbol: %s | Qty: %d | Buy: $%s | Current: $%s | Value: $%s | Gain/Loss: $%s"
    s.symbol
    s.quantity
    (string_of_float2 s.purchase_price)
    (string_of_float2 s.current_price)
    (string_of_float2 value)
    (string_of_float2 gain)

let rec print_portfolio (p : portfolio) : unit =
  match p with
  | [] -> ()
  | s :: rest ->
      Printf.printf "%s\n" (string_of_stock s);
      print_portfolio rest

let view_portfolio (p : portfolio) : unit =
  if p = [] then
    Printf.printf "Portfolio is empty.\n"
  else (
    print_portfolio p;
    let total_value = total_portfolio_value p in
    let total_gain = overall_gain_loss p in
    Printf.printf "\n";
    Printf.printf "Total Current Value: $%s\n" (string_of_float2 total_value);
    Printf.printf "Overall Gain/Loss:  $%s\n" (string_of_float2 total_gain);
    Printf.printf "-----------------------------------------------------------------------\n"
  )

(* ---------- Test Cases ---------- *)

let test_find_stock () =
  let p =
    [
      { symbol = "AAPL"; quantity = 10; purchase_price = 150.0; current_price = 170.0 };
      { symbol = "MSFT"; quantity = 5; purchase_price = 300.0; current_price = 310.0 };
    ]
  in
  (match find_stock "aapl" p with
   | None -> Printf.printf "TEST find_stock AAPL: FAILED (expected Some).\n"
   | Some s ->
       Printf.printf "TEST find_stock AAPL: PASSED (found %s).\n" s.symbol);
  (match find_stock "GOOG" p with
   | None ->
       Printf.printf "TEST find_stock GOOG: PASSED (correctly not found).\n"
   | Some _ ->
       Printf.printf "TEST find_stock GOOG: FAILED (should not find).\n")

let test_add_and_remove () =
  let empty : portfolio = [] in
  let s1 = { symbol = "AAPL"; quantity = 10; purchase_price = 150.0; current_price = 160.0 } in
  let s2 = { symbol = "MSFT"; quantity = 5; purchase_price = 300.0; current_price = 305.0 } in
  let p1 = add_stock s1 empty in
  let p2 = add_stock s2 p1 in
  Printf.printf "TEST add_stock: portfolio after adding AAPL and MSFT:\n";
  view_portfolio p2;

  let p3 = remove_stock "AAPL" p2 in
  Printf.printf "TEST remove_stock existing (AAPL removed):\n";
  view_portfolio p3;

  let p4 = remove_stock "GOOG" p3 in
  Printf.printf "TEST remove_stock non-existing (GOOG - no change expected):\n";
  view_portfolio p4

let test_update_price () =
  let p =
    [
      { symbol = "AAPL"; quantity = 10; purchase_price = 150.0; current_price = 150.0 };
      { symbol = "TSLA"; quantity = 3; purchase_price = 700.0; current_price = 650.0 };
    ]
  in
  Printf.printf "TEST update_price - before:\n";
  view_portfolio p;

  let p1 = update_price "AAPL" 180.0 p in
  Printf.printf "After updating AAPL price to 180:\n";
  view_portfolio p1;

  let p2 = update_price "GOOG" 2000.0 p1 in
  Printf.printf "After trying to update GOOG (non-existing):\n";
  view_portfolio p2


let () =
  Printf.printf "Running Financial Portfolio Manager tests...\n\n";
  test_find_stock ();
  Printf.printf "\n";
  test_add_and_remove ();
  Printf.printf "\n";
  test_update_price ();
  Printf.printf "\n";
  Printf.printf "\nAll tests executed.\n"
