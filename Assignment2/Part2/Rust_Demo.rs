use std::thread;
use std::time::Duration;

// A small heap object
#[derive(Debug)]
struct Blob {
    data: Vec<u8>,
}

fn grow_in_place(b: &mut Blob, n: usize) {      // borrow mutably (no new owner)
    b.data.extend((0..n as u8).map(|x| x));
}

fn make_owner(n: usize) -> Blob {               // return ownership (move)
    Blob { data: vec![42; n] }
}

fn main() {
    // 1) Allocate on heap via Vec (owned by `a`)
    let mut a = Blob { data: vec![1, 2, 3] };

    // 2) Borrow mutably; no copies, no GC
    grow_in_place(&mut a, 100_000);

    // 3) Move ownership (no clone)
    let b = make_owner(1_000_000);
    println!("a.len={}  b.len={}", a.data.len(), b.data.len());

    // 4) `a` and `b` drop automatically here—deterministic frees
    thread::sleep(Duration::from_millis(50));
}

/*
// Uncomment to see Rust catch a dangling reference at COMPILE TIME:

fn bad() {
    let r: &Vec<u8>;
    {
        let v = vec![1, 2, 3]; // `v` freed at end of this block
        r = &v;                // ERROR: `v` does not live long enough
    }
    println!("{}", r.len());
}
*/

