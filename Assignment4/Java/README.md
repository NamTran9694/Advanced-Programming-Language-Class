# Schedule Java Program.  
## Requirements:
* JDK 17+ (needs both java and javac on PATH)

## Run
cd java\
javac Schedulev1.java\
java schedulev1

## What you’ll see
* Printed weekly schedule + headcount/feasibility warnings if applicable.

## Edit employees
* Open java/Schedulev1.java
* In main, modify the employees.add(new Employee(...)) entries to match your test set.

## How It Works
* Per day, per shift, the program tries to assign exactly 2 people.
* It honors ranked preferences first (rounds: 1st choice, 2nd choice, …).
* If still short, it uses fallback: any eligible employee.
* Fairness rule: among candidates, it prefers employees with fewer days worked; breaks ties randomly (fixed seed for reproducibility).
* If it can’t reach 2 because of constraints (e.g., everyone hit 5 days), it prints a clear warning.
