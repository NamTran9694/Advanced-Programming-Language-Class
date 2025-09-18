def make_adder(delta):
    count = 0
    def adder(x):
        nonlocal count            # allow mutation of the enclosed variable
        count += 1
        return x + delta, count
    return adder

# Late-binding pitfall: all lambdas see the *final* i unless captured via default
bad = [lambda: i for i in range(3)]
good = [lambda i=i: i for i in range(3)]

# Demo
add7 = make_adder(7)
print(add5(10))     # (17, 1)
print(add5(2))      # (9, 2)
print([f() for f in bad])   # [2, 2, 2]  (pitfall)
print([f() for f in good])  # [0, 1, 2]  (correct)
