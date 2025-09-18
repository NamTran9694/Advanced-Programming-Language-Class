#include <iostream>
#include <vector>
#include <functional>
#include <utility>

auto make_adder(int delta) {
    int count = 0;
    // capture delta and count by value; 'mutable' lets us modify the captured copy
    return [delta, count](int x) mutable {
        ++count;
        return std::pair<int,int>{x + delta, count};
    };
}

int main() {
    // Loop-closure: by-reference vs by-value capture
    std::vector<std::function<int()>> bad, good;
    for (int i = 0; i < 3; ++i) bad.push_back([&i]{ return i; });
    for (int i = 0; i < 3; ++i) good.push_back([i]{ return i; });

    auto add5 = make_adder(5);
    auto r1 = add5(10); std::cout << r1.first << " " << r1.second << "\n"; // 15 1
    auto r2 = add5(2);  std::cout << r2.first << " " << r2.second << "\n"; // 7  2

    for (auto &f : bad)  std::cout << f() << " "; std::cout << "\n"; // 3 3 3 (pitfall)
    for (auto &f : good) std::cout << f() << " "; std::cout << "\n"; // 0 1 2 (correct)
}

