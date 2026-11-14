# Closures

A *closure* is an anonymous function that you can store in a variable. It is
written with its parameters between bars, followed by its body: `|x| x + 1`
takes one parameter, and `|| println!("hi")` takes none. Unlike a function
defined with `fn`, a closure can use variables from the place where it is
defined. We say the closure *captures* those variables.

A closure captures each variable in the least demanding way its body needs:
it takes an immutable borrow if the body only reads the variable, a mutable
borrow if the body modifies it, and ownership if the body moves it. Which one
Rust picks decides what you can do with the variable while the closure is
still in use, and afterwards.

## Capturing by Immutable Borrow

The closure `show` below only reads `s`, so it captures `s` by immutable
borrow. Hover over the arrow on Line 3 to see the capture. Like any immutable
borrow, it shares access to the resource: `main` can still read `s` on Line 5
while `show` holds its borrow.

```rv
fn main() {
    let s = String::from("hello");
    let show = || println!("{}", s);
    show();
    println!("{}", s);
    show();
}
```

This code prints `hello` three times.

The borrow lasts as long as the closure is still going to be used, which here
is until its last call on Line 6. The visualization draws the capture, but not
what the closure's body does each time it is called: the reads of `s` that
happen when `show` is called on Lines 4 and 6 do not appear on `s`'s timeline.

## Capturing by Mutable Borrow

The closure `exclaim` below modifies `s` by pushing onto it, so it captures `s`
by mutable borrow. Calling `exclaim` changes what it has captured, so the
closure variable itself must be declared with `let mut`, just like `s`.

```rv
fn main() {
    let mut s = String::from("hello");
    let mut exclaim = || s.push_str("!");
    exclaim();
    exclaim();
    println!("{}", s);
}
```

This code prints `hello!!`.

As with any mutable borrow, nothing else may use `s` while the borrow is live,
and the borrow is live until the closure's last use, on Line 5. After that, `s`
can be used again, so printing it on Line 6 is fine. Using `s` between the two
calls is an error, because `exclaim` is still going to be used afterwards:

```rust
fn main() {
    let mut s = String::from("hello");
    let mut exclaim = || s.push_str("!");
    exclaim();
    println!("{}", s); // ERROR: s is mutably borrowed by exclaim
    exclaim();
}
```

The compiler error here is `cannot borrow s as immutable because it is also
borrowed as mutable`.

## `move` Closures

Writing `move` before a closure makes it take ownership of the variables it
uses, even if its body only reads them. (A `Copy` value, such as an integer, is
copied into the closure instead, so the variable can still be used.) Below, the
closure `show` only prints `s`, but because of `move`, ownership of `s`'s
resource is moved into the closure on Line 3.

```rv
fn main() {
    let s = String::from("hello");
    let show = move || println!("{}", s);
    show();
    show();
}
```

This code prints `hello` twice.

The closure now owns the resource, so `s` can no longer be used after Line 3:
adding `println!("{}", s);` at the end of `main` would give the compiler error
`borrow of moved value: s`. Calling `show` only reads the resource it owns, so
it can be called as many times as we like. The resource is dropped when `show`
goes out of scope at the end of `main`, and nothing is dropped for `s`.

`move` is needed when a closure must outlive the variables it uses. For
example, a closure passed to `std::thread::spawn` may still be running after
the function that created it has returned, so it cannot borrow that function's
variables.

## Closures That Can Only Be Called Once

A closure takes ownership even without `move` when its body moves a captured
variable. The body of `give_back` below is just `s`, so calling it moves the
resource *out* of the closure, and the call's result is moved into `t`.

```rv
fn main() {
    let s = String::from("hello");
    let give_back = || s;
    let t = give_back();
    println!("{}", t);
}
```

This code prints `hello`.

After the first call, the closure no longer owns the resource, so there would be
nothing to give back a second time. Rust therefore lets this closure be called
only once: the call on Line 4 moves `give_back` itself, and nothing is dropped
when `give_back` and `s` go out of scope. Calling `give_back()` a second time
would give the compiler error `use of moved value: give_back`.
