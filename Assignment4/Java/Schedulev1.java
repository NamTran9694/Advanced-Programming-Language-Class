import java.util.*;
import java.util.stream.Collectors;

public class Schedulev1 {

    // Constants
    static final List<String> DAYS = Arrays.asList("Mon","Tue","Wed","Thu","Fri","Sat","Sun");
    static final List<String> SHIFTS = Arrays.asList("morning","afternoon","evening");

    static final int MIN_PER_SHIFT = 2;
    static final long RANDOM_SEED = 42L;
    static final Random RNG = new Random(RANDOM_SEED);

    // Employee model
    static class Employee {
        final String name;
        final Map<String, List<String>> prefs;     // day -> ranked list of shifts
        final Map<String, String> assigned;        // day -> shift or null
        int daysWorked;

        Employee(String name, Map<String, List<String>> weeklyPrefs) {
            this.name = name;
            this.prefs = new LinkedHashMap<>();
            for (String d : DAYS) {
                List<String> p = weeklyPrefs.getOrDefault(d, Collections.emptyList());
                this.prefs.put(d, new ArrayList<>(p));
            }
            this.assigned = new LinkedHashMap<>();
            for (String d : DAYS) this.assigned.put(d, null);
            this.daysWorked = 0;
        }

        boolean canWork(String day) {
            return assigned.get(day) == null && daysWorked < 5;
        }
    }

    // Core scheduler: no max-per-shift; fill exactly the minimum if possible
    static Map<String, Map<String, List<String>>> schedule(List<Employee> employees) {
        int totalRequired = DAYS.size() * SHIFTS.size() * MIN_PER_SHIFT; // 42
        int totalCapacity = employees.size() * 5;                         // ≤5 per employee
        if (totalCapacity < totalRequired) {
            int neededEmployees = ((totalRequired + 4) / 5) - employees.size();
            System.out.println("[WARN] Infeasible: need " + totalRequired + " person-shifts but only have "
                    + totalCapacity + ". Add " + Math.max(1, neededEmployees)
                    + "+ employees or relax the 5-day limit.");
        }

        // schedule[day][shift] = list of employee names
        Map<String, Map<String, List<String>>> sched = new LinkedHashMap<>();
        for (String d : DAYS) {
            Map<String, List<String>> perShift = new LinkedHashMap<>();
            for (String s : SHIFTS) perShift.put(s, new ArrayList<>());
            sched.put(d, perShift);
        }

        // Helpers
        java.util.function.BiConsumer<String, Employee> incWork = (day, emp) -> {
            String sh = emp.assigned.get(day);
            emp.assigned.put(day, sh);
            emp.daysWorked++;
        };

        class Util {
            void assign(String day, String shift, Employee e) {
                sched.get(day).get(shift).add(e.name);
                e.assigned.put(day, shift);
                e.daysWorked++;
            }

            List<Employee> fairnessPick(List<Employee> pool, int k) {
                if (pool == null || pool.isEmpty() || k <= 0) return Collections.emptyList();
                // Sort by daysWorked ascending
                pool = new ArrayList<>(pool);
                pool.sort(Comparator.comparingInt(e -> e.daysWorked));

                List<Employee> chosen = new ArrayList<>();
                int i = 0;
                while (i < pool.size() && chosen.size() < k) {
                    int tierDays = pool.get(i).daysWorked;
                    List<Employee> tier = new ArrayList<>();
                    while (i < pool.size() && pool.get(i).daysWorked == tierDays) {
                        tier.add(pool.get(i));
                        i++;
                    }
                    // random within fairness tier
                    Collections.shuffle(tier, RNG);
                    for (Employee e : tier) {
                        if (chosen.size() == k) break;
                        chosen.add(e);
                    }
                }
                return chosen;
            }
        }
        Util util = new Util();

        // For each day, fill each shift to the minimum using ranked preferences first
        for (String day : DAYS) {

            // Per-shift fill
            for (String shift : SHIFTS) {
                int needed = MIN_PER_SHIFT - sched.get(day).get(shift).size();
                if (needed <= 0) continue;

                // Determine the maximum preference length among eligibles for this day
                int maxRank = 0;
                for (Employee e : employees) {
                    if (e.canWork(day)) {
                        List<String> p = e.prefs.getOrDefault(day, Collections.emptyList());
                        if (p.size() > maxRank) maxRank = p.size();
                    }
                }

                // Ranked passes: rank 0,1,2,...
                for (int rank = 0; rank < maxRank && needed > 0; rank++) {
                    List<Employee> candidates = new ArrayList<>();
                    for (Employee e : employees) {
                        if (!e.canWork(day)) continue;
                        List<String> p = e.prefs.getOrDefault(day, Collections.emptyList());
                        if (p.size() > rank && shift.equals(p.get(rank))) {
                            candidates.add(e);
                        }
                    }
                    List<Employee> picks = util.fairnessPick(candidates, needed);
                    for (Employee emp : picks) util.assign(day, shift, emp);
                    needed -= picks.size();
                }

                // Fallback: any eligible if still needed
                if (needed > 0) {
                    List<Employee> fallback = employees.stream()
                            .filter(e -> e.canWork(day))
                            .collect(Collectors.toList());
                    List<Employee> picks = util.fairnessPick(fallback, needed);
                    for (Employee emp : picks) util.assign(day, shift, emp);
                    needed -= picks.size();
                }

                if (needed > 0) {
                    System.out.println("[WARN] " + day + " " + shift + ": staffed "
                            + (MIN_PER_SHIFT - needed) + "/" + MIN_PER_SHIFT
                            + " (no eligible employees left under the ≤5-days rule).");
                }
            }
        }

        return sched;
    }

    static void printSchedule(Map<String, Map<String, List<String>>> sched) {
        System.out.println("=== Final Weekly Schedule (min-only) ===");
        for (String day : DAYS) {
            System.out.println("\n" + day + ":");
            for (String shift : SHIFTS) {
                List<String> names = sched.get(day).get(shift);
                String line = (names.isEmpty()) ? "(none)" : String.join(", ", names);
                System.out.printf("  %-9s: %s%n", shift, line);
            }
        }
    }

    public static void main(String[] args) {
        List<Employee> employees = new ArrayList<>();

        employees.add(new Employee("Alice", mapOf(
                "Mon", listOf("morning","evening"),
                "Tue", listOf("morning"),
                "Wed", listOf("morning"),
                "Thu", listOf("afternoon"),
                "Fri", listOf("evening"),
                "Sat", listOf("morning")
        )));
        employees.add(new Employee("Bob", mapOf(
                "Mon", listOf("morning"),
                "Tue", listOf("afternoon"),
                "Wed", listOf("evening"),
                "Thu", listOf("morning"),
                "Fri", listOf("afternoon"),
                "Sun", listOf("evening")
        )));
        employees.add(new Employee("Carol", mapOf(
                "Mon", listOf("evening"),
                "Tue", listOf("evening"),
                "Wed", listOf("afternoon"),
                "Thu", listOf("afternoon"),
                "Fri", listOf("morning"),
                "Sat", listOf("morning"),
                "Sun", listOf("afternoon")
        )));
        employees.add(new Employee("Dan", mapOf(
                "Mon", listOf("morning"),
                "Tue", listOf("morning"),
                "Wed", listOf("morning"),
                "Thu", listOf("morning"),
                "Fri", listOf("morning")
        )));
        employees.add(new Employee("Eve", mapOf(
                "Mon", listOf("afternoon"),
                "Tue", listOf("afternoon"),
                "Wed", listOf("afternoon"),
                "Thu", listOf("evening"),
                "Fri", listOf("evening"),
                "Sat", listOf("evening")
        )));
        employees.add(new Employee("Frank", mapOf(
                "Mon", listOf("morning"),
                "Wed", listOf("evening"),
                "Thu", listOf("afternoon"),
                "Sat", listOf("afternoon"),
                "Sun", listOf("morning")
        )));
        employees.add(new Employee("Grace", mapOf(
                "Tue", listOf("evening"),
                "Wed", listOf("evening"),
                "Thu", listOf("morning"),
                "Fri", listOf("afternoon"),
                "Sat", listOf("evening"),
                "Sun", listOf("afternoon")
        )));
        employees.add(new Employee("Nam", mapOf(
                "Tue", listOf("evening"),
                "Wed", listOf("evening"),
                "Thu", listOf("morning"),
                "Fri", listOf("afternoon"),
                "Sat", listOf("evening"),
                "Sun", listOf("afternoon")
        )));
        employees.add(new Employee("Thien", mapOf(
                "Tue", listOf("evening"),
                "Wed", listOf("evening"),
                "Thu", listOf("morning"),
                "Fri", listOf("afternoon"),
                "Sat", listOf("evening"),
                "Sun", listOf("afternoon")
        )));

        Map<String, Map<String, List<String>>> sched = schedule(employees);
        printSchedule(sched);

        // Optional: quick validation
        validate(employees, sched);
    }

    // --- Small helpers to construct maps/lists tersely (works on Java 8+) ---

    static Map<String, List<String>> mapOf(Object... kv) {
        Map<String, List<String>> m = new LinkedHashMap<>();
        for (int i = 0; i < kv.length; i += 2) {
            String k = (String) kv[i];
            @SuppressWarnings("unchecked")
            List<String> v = (List<String>) kv[i + 1];
            m.put(k, v);
        }
        return m;
    }

    static List<String> listOf(String... items) {
        return new ArrayList<>(Arrays.asList(items));
    }

    // Quick sanity checks
    static void validate(List<Employee> employees, Map<String, Map<String, List<String>>> sched) {
        List<String> violations = new ArrayList<>();

        // A) At least MIN_PER_SHIFT per day/shift
        for (String d : DAYS) {
            for (String s : SHIFTS) {
                if (sched.get(d).get(s).size() < MIN_PER_SHIFT) {
                    violations.add("Understaffed: " + d + " " + s + " -> "
                            + sched.get(d).get(s).size() + "/" + MIN_PER_SHIFT);
                }
            }
        }

        // B) ≤1 shift per day per employee (implicit by design; still check)
        Map<String, Map<String, Integer>> perEmpPerDay = new HashMap<>();
        for (String d : DAYS) {
            for (String s : SHIFTS) {
                for (String name : sched.get(d).get(s)) {
                    perEmpPerDay.putIfAbsent(name, new HashMap<>());
                    Map<String, Integer> perDay = perEmpPerDay.get(name);
                    perDay.put(d, perDay.getOrDefault(d, 0) + 1);
                }
            }
        }
        for (Map.Entry<String, Map<String, Integer>> e : perEmpPerDay.entrySet()) {
            for (Map.Entry<String, Integer> dayCnt : e.getValue().entrySet()) {
                if (dayCnt.getValue() > 1) {
                    violations.add("Double-booked: " + e.getKey() + " on " + dayCnt.getKey());
                }
            }
        }

        // C) ≤5 days per employee
        Map<String, Integer> daysWorked = new HashMap<>();
        for (String d : DAYS) {
            Set<String> workedToday = new HashSet<>();
            for (String s : SHIFTS) {
                for (String name : sched.get(d).get(s)) workedToday.add(name);
            }
            for (String name : workedToday) {
                daysWorked.put(name, daysWorked.getOrDefault(name, 0) + 1);
            }
        }
        for (Map.Entry<String, Integer> e : daysWorked.entrySet()) {
            if (e.getValue() > 5) {
                violations.add(e.getKey() + " worked " + e.getValue() + " days (>5)");
            }
        }

        System.out.println("\n--- Validation ---");
        if (violations.isEmpty()) System.out.println("All constraints satisfied.");
        else {
            System.out.println("Violations:");
            for (String v : violations) System.out.println(" - " + v);
        }
    }
}

