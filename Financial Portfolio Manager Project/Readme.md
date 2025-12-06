# 📘 Financial Portfolio Manager – OCaml Project

## **Overview**

This project implements a **Basic Financial Portfolio Manager** in OCaml as part of a Programming Languages course assignment. The program allows users to create and manage a stock portfolio by adding, removing, and updating stock entries, viewing financial summaries, and calculating total value and gain/loss.

The system demonstrates core **functional programming concepts**, including recursion, pattern matching, immutability, and OCaml’s strong static type system.

---

## **Features**

### Add a Stock
- Inserts a new stock into the portfolio.
- If the symbol already exists, it is replaced.

### Remove a Stock
- Removes a stock entry by its ticker symbol.
- If the symbol does not exist, portfolio remains unchanged.

### Update Stock Price
- Updates the `current_price` field of an existing stock.
- Handles missing symbols gracefully.

### View Portfolio
Displays:
- Stock symbol  
- Quantity  
- Purchase price  
- Current price  
- Current total value  
- Gain or loss  

Also prints:
- **Total portfolio value**
- **Overall portfolio gain/loss**

### Recursive Calculations
All list operations (add, remove, update, totals) use **recursion**, not loops.

### Option Type Handling
Stock lookup returns:
- `Some stock` when found  
- `None` when not found  



## **How to Compile and Run**

This project requires OCaml and OPAM. It was developed and tested using:

- **Windows 11 + WSL2 (Ubuntu)**
- **OCaml 4.14.1**
- **OPAM 2.1.5**

### **Compile**

```bash
ocamlc -o portfolio portfolio.ml
.\portfolio
