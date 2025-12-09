import sys
from typing import List


class StatisticsCalculator:

    def __init__(self, data: List[int]) -> None:
        if not data:
            raise ValueError("Data list cannot be empty.")
        self.data = data

    def mean(self) -> float:
        total = sum(self.data)
        return total / len(self.data)

    def median(self) -> float:
        sorted_data = sorted(self.data)
        n = len(sorted_data)
        mid = n // 2
        if n % 2 == 1:
            return float(sorted_data[mid])
        else:
            return (sorted_data[mid - 1] + sorted_data[mid]) / 2.0

    def modes(self) -> List[int]:
        # frequency dictionary: value -> count
        freq = {}
        for x in self.data:
            freq[x] = freq.get(x, 0) + 1

        max_count = max(freq.values())
        # collect all values with max frequency
        return [value for value, count in freq.items() if count == max_count]


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} num1 num2 ...")
        sys.exit(1)

    try:
        data = [int(x) for x in sys.argv[1:]]
    except ValueError:
        print("All arguments must be integers.")
        sys.exit(1)

    calc = StatisticsCalculator(data)

    print(f"Number of elements: {len(data)}")
    print(f"Mean:   {calc.mean():.2f}")
    print(f"Median: {calc.median():.2f}")
    modes = calc.modes()
    print(f"Mode(s): {modes}")


if __name__ == "__main__":
    main()
