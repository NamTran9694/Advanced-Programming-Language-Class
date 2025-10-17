import random
from collections import defaultdict, deque

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
SHIFTS = ["morning", "afternoon", "evening"]

MIN_PER_SHIFT = 2
MAX_PER_SHIFT = 3         # Used to define "full"
RANDOM_SEED = 42          # Reproducible random choices
random.seed(RANDOM_SEED)

class Employee:
    def __init__(self, name, weekly_prefs):
        """
        weekly_prefs: dict[day] -> list[str] ordered by priority (e.g., ["morning","evening"])
        If a day is missing or empty, the employee has no preference that day.
        """
        self.name = name
        self.prefs = {d: list(weekly_prefs.get(d, [])) for d in DAYS}
        self.assigned = {d: None for d in DAYS}   # day -> shift or None
        self.days_worked = 0

    def can_work(self, day):
        return self.assigned[day] is None and self.days_worked < 5

def schedule(employees):
    # schedule[day][shift] = list of employee names
    schedule = {d: {s: [] for s in SHIFTS} for d in DAYS}

    # Helpers
    def has_capacity(day, shift):
        return len(schedule[day][shift]) < MAX_PER_SHIFT

    def assign(day, shift, emp: Employee):
        schedule[day][shift].append(emp.name)
        emp.assigned[day] = shift
        emp.days_worked += 1

    # 1) First pass: assign by ranked preferences, capping at MAX_PER_SHIFT.
    #    If too many want the same shift, randomly keep up to capacity; others go to conflict.
    next_day_conflicts = {d: deque() for d in DAYS}

    for day in DAYS:
        # Collect (emp, ranked_prefs_for_day)
        day_interested = [(e, e.prefs.get(day, [])) for e in employees if e.can_work(day) and e.prefs.get(day)]
        # Try in ranked rounds: first choices round, second choices round, etc.
        max_rank_len = max((len(p) for _, p in day_interested), default=0)
        for rank in range(max_rank_len):
            # For each shift, gather candidates whose rank-th choice is this shift
            for shift in SHIFTS:
                candidates = [e for (e, p) in day_interested
                              if len(p) > rank and p[rank] == shift and e.can_work(day)]
                if not candidates:
                    continue
                # If capacity available, take up to space; overflow becomes conflicts (to be tried later)
                space = MAX_PER_SHIFT - len(schedule[day][shift])
                if space <= 0:
                    # Everyone here conflicts for this shift at this rank; they'll try next ranks/day
                    continue
                if len(candidates) <= space:
                    for emp in candidates:
                        if e_can := emp.can_work(day):
                            assign(day, shift, emp)
                else:
                    chosen = set(random.sample(candidates, space))
                    for emp in candidates:
                        if emp in chosen and emp.can_work(day):
                            assign(day, shift, emp)
                        # Unchosen remain eligible to try lower-ranked choices later

        # Any still-unassigned who had a preference today become conflicts to try next day
        for e, p in day_interested:
            if e.assigned[day] is None:
                next_day_conflicts[day].append(e)

        # 2) Bring forward conflicts from the previous day to try "next-day" resolution (today)
        prev_day = DAYS[(DAYS.index(day) - 1) % 7]
        carry = list(next_day_conflicts[prev_day])
        next_day_conflicts[prev_day].clear()
        for emp in carry:
            if not emp.can_work(day):
                continue
            # Try any shift today by ranked preferences first, then any available
            prefs_today = emp.prefs.get(day, [])
            placed = False
            # Try ranked
            for shift in prefs_today:
                if has_capacity(day, shift):
                    assign(day, shift, emp)
                    placed = True
                    break
            # Try any shift if still not placed
            if not placed:
                for shift in SHIFTS:
                    if has_capacity(day, shift):
                        assign(day, shift, emp)
                        placed = True
                        break
            # If still not placed, push conflict forward again
            if not placed:
                next_day_conflicts[day].append(emp)

    # 3) Ensure minimum staffing: if shift has < MIN_PER_SHIFT, randomly fill from eligible employees
    for day in DAYS:
        for shift in SHIFTS:
            while len(schedule[day][shift]) < MIN_PER_SHIFT:
                # Choose from employees who can work this day and not already assigned
                candidates = [e for e in employees if e.can_work(day)]
                if not candidates:
                    break  # Cannot fill further
                chosen = random.choice(candidates)
                assign(day, shift, chosen)

    return schedule

def print_schedule(schedule):
    print("=== Final Weekly Schedule ===")
    for day in DAYS:
        print(f"\n{day}:")
        for shift in SHIFTS:
            names = ", ".join(schedule[day][shift]) if schedule[day][shift] else "(none)"
            print(f"  {shift:<9}: {names}")

if __name__ == "__main__":
    # ----- Example data (edit freely) -----
    # Priority-ranked preferences per day; omit a day or give [] if unavailable/no preference.
    employees = [
        Employee("Alice", {
            "Mon": ["morning", "evening"], "Tue": ["morning"], "Wed": ["morning"],
            "Thu": ["afternoon"], "Fri": ["evening"], "Sat": ["morning"], "Sun": []
        }),
        Employee("Bob", {
            "Mon": ["morning"], "Tue": ["afternoon"], "Wed": ["evening"],
            "Thu": ["morning"], "Fri": ["afternoon"], "Sat": [], "Sun": ["evening"]
        }),
        Employee("Carol", {
            "Mon": ["evening"], "Tue": ["evening"], "Wed": ["afternoon"],
            "Thu": ["afternoon"], "Fri": ["morning"], "Sat": ["morning"], "Sun": ["afternoon"]
        }),
        Employee("Dan", {
            "Mon": ["morning"], "Tue": ["morning"], "Wed": ["morning"],
            "Thu": ["morning"], "Fri": ["morning"], "Sat": [], "Sun": []
        }),
        Employee("Eve", {
            "Mon": ["afternoon"], "Tue": ["afternoon"], "Wed": ["afternoon"],
            "Thu": ["evening"], "Fri": ["evening"], "Sat": ["evening"], "Sun": []
        }),
        Employee("Frank", {
            "Mon": ["morning"], "Tue": [], "Wed": ["evening"],
            "Thu": ["afternoon"], "Fri": [], "Sat": ["afternoon"], "Sun": ["morning"]
        }),
        Employee("Grace", {
            "Mon": [], "Tue": ["evening"], "Wed": ["evening"],
            "Thu": ["morning"], "Fri": ["afternoon"], "Sat": ["evening"], "Sun": ["afternoon"]
        }),
        Employee("Nam", {
            "Mon": [], "Tue": ["evening"], "Wed": ["evening"],
            "Thu": ["morning"], "Fri": ["afternoon"], "Sat": ["evening"], "Sun": ["afternoon"]
        }),
        Employee("Thien", {
            "Mon": [], "Tue": ["evening"], "Wed": ["evening"],
            "Thu": ["morning"], "Fri": ["afternoon"], "Sat": ["evening"], "Sun": ["afternoon"]
        }),
    ]

    sched = schedule(employees)
    print_schedule(sched)

