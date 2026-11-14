# Loops

Rust has three kinds of loops: `for`, `while`, and `loop`. A loop body runs
many times, so the borrow checker must make sure that each iteration leaves
things in a state where the next iteration (and the code after the loop) is
still safe.

## Borrowing in a Loop

A `for` loop runs its body once for each value in a range or collection. Here,
`0..3` is the range of integers from `0` up to (but not including) `3`, and `_`
means we do not need a name for the current integer. Each iteration takes a new
immutable borrow of `s` and passes it to `print_string`. That borrow ends when
`print_string` returns, so `s` still owns its resource after the loop.

```rv
fn main() {
    let s = String::from("hello");
    for _ in 0..3 {
        print_string(&s);
    }
    println!("{}", s);
}

fn print_string(r: &String) {
    println!("{}", r);
}
```

This code prints `hello` four times.

## Moving in a Loop

Moving a resource inside a loop body is a problem: after the first iteration
moves `s`, there is nothing left to move on the second iteration.

```rust
fn main() {
    let s = String::from("hello");
    for _ in 0..3 {
        takes_ownership(s); // ERROR: s was moved in the previous iteration
    }
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}
```

The compiler error here is `use of moved value: s`, and it points at the move
with `value moved here, in previous iteration of loop`.

One way to fix this is to give `s` a new resource before the next iteration
needs it. Assigning to `s` after the move makes `s` an owner again, so every
iteration has a resource to move.

```rv
fn main() {
    let mut s = String::from("first");
    for _ in 0..3 {
        takes_ownership(s);
        s = String::from("next");
    }
    println!("{}", s);
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}
```

This code prints `first`, `next`, `next`, and then `next` once more from the
final `println!`.

Each resource moved into `takes_ownership` is dropped at the end of that call,
when `some_string` goes out of scope. The last resource assigned to `s` is never
moved, so it is dropped when `s` goes out of scope at the end of `main`.

## Dropping in Each Iteration

A variable declared inside a loop body goes out of scope at the end of each
iteration. In the example below, every iteration creates a new `String` owned
by `s`, and that resource is dropped at the end of the iteration, before the
next one begins. Three resources are created and three are dropped.

```rv
fn main() {
    for i in 0..3 {
        let s = String::from("hello");
        println!("{} {}", i, s);
    }
}
```

This code prints `0 hello`, `1 hello`, and `2 hello` on separate lines.

## `while` Loops

A `while` loop runs its body as long as its condition is true. Here, the
condition `s.len() < 6` takes an immutable borrow of `s` (to compute its
length), and the body takes a mutable borrow of `s` (to push onto it). Each
borrow ends as soon as the method call returns, so the two never overlap, even
though they alternate on every iteration.

```rv
fn main() {
    let mut s = String::new();
    while s.len() < 6 {
        s.push_str("ab");
    }
    println!("{}", s);
}
```

This code prints `ababab`.

## `loop` and `break`

A `loop` runs forever unless it is stopped with `break`. Like `if`, `loop` is
an expression, and `break` can give it a value. Below, `break s;` ends the loop
and moves `s`'s resource out of it, so ownership moves to `t`. The
visualization draws this move on Line 8, where the `let` statement that binds
`t` finishes.

```rv
fn main() {
    let mut s = String::new();
    let t = loop {
        s.push_str("ab");
        if s.len() >= 6 {
            break s;
        }
    };
    println!("{}", t);
}
```

This code prints `ababab`.

Unlike `takes_ownership(s)` in the `for` loop above, the move here is fine:
`break` leaves the loop, so no later iteration can try to use `s` again. Since
`s` has been moved by the time it goes out of scope, nothing is dropped for
`s`; the resource is dropped when `t` goes out of scope.
