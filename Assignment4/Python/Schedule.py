import random
from collections import defaultdict, deque

DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
SHIFTS = ["morning", "afternoon", "evening"]

MIN_PER_SHIFT = 2
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
    """
    constraints:
      - ≤1 shift per day per employee
      - ≤5 days per employee per week
    """
    # Feasibility check (with exact-min plan, total demand is fixed)
    total_required = len(DAYS) * len(SHIFTS) * MIN_PER_SHIFT   # 42
    total_capacity = len(employees) * 5                        # ≤5 days/emp
    if total_capacity < total_required:
        print(f"[WARN] Infeasible: need {total_required} person-shifts but only have "
              f"{total_capacity}. Add {((total_required + 4)//5) - len(employees)}+ employees "
              f"or relax the 5-day limit.")

    # schedule[day][shift] = list of employee names
    schedule = {d: {s: [] for s in SHIFTS} for d in DAYS}

    def can_work(emp, day):
        return emp.assigned[day] is None and emp.days_worked < 5

    def assign(day, shift, emp):
        schedule[day][shift].append(emp.name)
        emp.assigned[day] = shift
        emp.days_worked += 1

    def fairness_pick(pool, k):
        """
        Pick up to k employees from pool, preferring the fewest days_worked;
        random among ties. Returns a list (unique) of chosen employees.
        """
        if not pool or k <= 0:
            return []
        # Sort by days_worked (ascending)
        pool_sorted = sorted(pool, key=lambda e: e.days_worked)
        # Build tiers of equal days_worked and draw from tiers until k filled
        chosen = []
        i = 0
        while i < len(pool_sorted) and len(chosen) < k:
            tier_days = pool_sorted[i].days_worked
            tier = []
            while i < len(pool_sorted) and pool_sorted[i].days_worked == tier_days:
                tier.append(pool_sorted[i])
                i += 1
            random.shuffle(tier)  # random within the fairness tier
            for e in tier:
                if len(chosen) == k:
                    break
                chosen.append(e)
        return chosen

    # For each day, fill each shift to the minimum using ranked preferences first
    for day in DAYS:
        # Pre-compute maximum preference length that exists for this day among eligibles
        def pref_list(emp):
            return emp.prefs.get(day, [])

        # We’ll fill each shift independently, but use the same ranked passes
        for shift in SHIFTS:
            needed = MIN_PER_SHIFT - len(schedule[day][shift])
            if needed <= 0:
                continue

            # Ranked passes: rank 0, 1, 2, ...
            max_rank = 0
            for e in employees:
                if can_work(e, day):
                    max_rank = max(max_rank, len(pref_list(e)))

            for rank in range(max_rank):
                if needed <= 0:
                    break
                # Candidates: eligible AND rank-th preference equals this shift
                candidates = [e for e in employees
                              if can_work(e, day)
                              and len(pref_list(e)) > rank
                              and pref_list(e)[rank] == shift]
                # Fairness: fewest days_worked first, random among ties
                picks = fairness_pick(candidates, needed)
                for emp in picks:
                    assign(day, shift, emp)
                needed -= len(picks)

            if needed > 0:
                # Fallback: any eligible (no preference for this shift today), still fair
                fallback = [e for e in employees if can_work(e, day)]
                picks = fairness_pick(fallback, needed)
                for emp in picks:
                    assign(day, shift, emp)
                needed -= len(picks)

            if needed > 0:
                print(f"[WARN] {day} {shift}: staffed {MIN_PER_SHIFT - needed}/{MIN_PER_SHIFT} "
                      f"(no eligible employees left under ≤5-days rule).")

    return schedule

def print_schedule(schedule):
    print("=== Final Weekly Schedule (min-only) ===")
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

