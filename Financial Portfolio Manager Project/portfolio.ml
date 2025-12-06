(* 1. Portfolio Data Structure *)
type stock = {
  symbol : string;
  quantity : float;
  purchase_price : float;
  current_price : float;
}

(* A portfolio is simply a list of stocks *)
type portfolio = stock list

(* Helper function to calculate gain/loss for a single stock *)
let calculate_stock_gain_loss (s : stock) : float =
  (s.current_price -. s.purchase_price) *. s.quantity

(* 2. Basic Functionality *)

(* Add Stock: Since lists are immutable, we return a new list with the stock added to the front *)
let add_stock (p : portfolio) (s : stock) : portfolio =
  s :: p

(* Remove Stock: Recursive function to filter out the stock by symbol *)
let rec remove_stock (p : portfolio) (target_symbol : string) : portfolio =
  match p with
  | [] -> [] (* Base case: Empty list, return empty *)
  | head :: tail ->
      if head.symbol = target_symbol then
        (* If symbol matches, skip this head and process the tail *)
        remove_stock tail target_symbol
      else
        (* If no match, keep head and process the tail *)
        head :: remove_stock tail target_symbol

(* Update Price: Recursive function to find a stock and update its price *)
(* Update Price: Recursive function to find a stock and update its price *)
let rec update_price (p : portfolio) (target_symbol : string) (new_price : float) : portfolio =
  match p with
  | [] -> [] (* Edge case: Stock not found, return empty list *)
  | head :: tail ->
      if head.symbol = target_symbol then
        (* Found it: update price and keep the tail *)
        { head with current_price = new_price } :: tail
      else
        (* Not found here: keep head, recurse on tail, AND PASS NEW_PRICE *)
        head :: update_price tail target_symbol new_price  (* <--- FIXED HERE *)

(* 3. Portfolio Calculations (Using Recursion) *)

(* Total Portfolio Value: Recursive sum of current values *)
let rec get_total_value (p : portfolio) : float =
  match p with
  | [] -> 0.0
  | head :: tail ->
      (head.quantity *. head.current_price) +. get_total_value tail

(* Overall Gain/Loss: Recursive sum of gains/losses *)
let rec get_overall_gain_loss (p : portfolio) : float =
  match p with
  | [] -> 0.0
  | head :: tail ->
      calculate_stock_gain_loss head +. get_overall_gain_loss tail

(* 4. View Functionality *)

(* Helper to print a single stock's details *)
let print_stock (s : stock) =
  let gain = calculate_stock_gain_loss s in
  Printf.printf "Symbol: %s | Qty: %.2f | Buy: %.2f | Curr: %.2f | Gain/Loss: %.2f\n"
    s.symbol s.quantity s.purchase_price s.current_price gain

(* View Portfolio: Recursively print all stocks *)
let rec view_portfolio (p : portfolio) : unit =
  match p with
  | [] -> ()
  | head :: tail ->
      print_stock head;
      view_portfolio tail

(* 5. Main Execution Block (for Testing) *)
let () =
  print_endline "--- Initializing Portfolio ---";
  let my_portfolio = [] in

  (* Test: Add Stocks *)
  let s1 = { symbol = "AAPL"; quantity = 10.0; purchase_price = 150.0; current_price = 155.0 } in
  let s2 = { symbol = "GOOG"; quantity = 5.0; purchase_price = 2800.0; current_price = 2750.0 } in
  let s3 = { symbol = "TSLA"; quantity = 20.0; purchase_price = 200.0; current_price = 210.0 } in
  
  let p1 = add_stock my_portfolio s1 in
  let p2 = add_stock p1 s2 in
  let p3 = add_stock p2 s3 in
  
  print_endline "\n--- Current Portfolio ---";
  view_portfolio p3;

  (* Test: Calculations *)
  Printf.printf "\nTotal Value: %.2f\n" (get_total_value p3);
  Printf.printf "Overall Gain/Loss: %.2f\n" (get_overall_gain_loss p3);

  (* Test: Update Price *)
  print_endline "\n--- Updating AAPL Price to 180.0 ---";
  let p4 = update_price p3 "AAPL" 180.0 in
  view_portfolio p4;
  Printf.printf "New Overall Gain/Loss: %.2f\n" (get_overall_gain_loss p4);

  (* Test: Remove Stock *)
  print_endline "\n--- Removing GOOG ---";
  let p5 = remove_stock p4 "GOOG" in
  view_portfolio p5;

  (* Test: Edge Cases *)
  print_endline "\n--- Edge Case: Updating non-existent stock (MSFT) ---";
  let p6 = update_price p5 "MSFT" 300.0 in
  (* Should look exactly the same as p5 *)
  view_portfolio p6; 
  
  print_endline "\n--- Edge Case: Removing non-existent stock (AMZN) ---";
  let p7 = remove_stock p6 "AMZN" in
  view_portfolio p7;
