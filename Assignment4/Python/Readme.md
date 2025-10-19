# Schedule Pythong Program.  
## Requirements:
* Python 3.9+ (no third-party packages needed)

## Run
cd python\
python Schedule.py

## What you’ll see
* A weekly schedule printed to the console
* Notes/warnings, e.g.:
* [NOTE] Only 7 employees provided... need at least 9.
* [WARN] Sat morning: staffed 1/2 (no eligible employees left under the ≤5-days rule).

## Edit employees
* Open python/Schedule.py
* In the __main__ block, add/remove employees or adjust their per-day ranked preferences:
  Employee("Alice", {"Mon": ["morning","evening"], "Tue":["morning"], ...})
* Re-run the script.
