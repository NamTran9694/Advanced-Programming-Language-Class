function makeAdder(delta) {
  let count = 0;
  return function (x) {
    count += 1;                 // closed-over lexical binding
    return [x + delta, count];
  };
}

// Loop-closure pitfall with var (function-scoped) vs let (block-scoped)
const bad = [];
for (var i = 0; i < 3; i++) bad.push(() => i);

const good = [];
for (let j = 0; j < 3; j++) good.push(() => j);

// Demo
const add5 = makeAdder(5);
console.log(add5(10));   // [15, 1]
console.log(add5(2));    // [7, 2]
console.log(bad.map(f => f()));   // [3, 3, 3]  (pitfall)
console.log(good.map(f => f()));  // [0, 1, 2]  (correct)

