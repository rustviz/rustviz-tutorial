# Conditionals

So far, every example has run straight through from top to bottom. Real
programs make decisions with `if` and `match`, and different branches can do
different things with a resource: one branch might move it while another only
borrows it. Rust checks your code before it runs, so it does not know which
branch will be taken. The borrow checker therefore makes sure the code is safe
*whichever* branch runs.

## Moving in One Branch

In the following example, the `if` branch only borrows `s` (to print it),
while the `else` branch moves `s` into `takes_ownership`.

```rv
fn main() {
    let s = String::from("hello");
    let keep = false;
    if keep {
        println!("{}", s);
    } else {
        takes_ownership(s);
    }
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}
```

This code prints `hello`.

Hover over the two segments of `s`'s timeline: the visualization shows the
`if` branch and the `else` branch separately. After the `if` expression, `s`
*might* have been moved, so Rust treats it as moved: any further use of `s` is
an error, even if we, the programmers, can see that `keep` is `false`.

```rust
fn main() {
    let s = String::from("hello");
    let keep = false;
    if keep {
        println!("{}", s);
    } else {
        takes_ownership(s);
    }
    println!("{}", s); // ERROR: s might have been moved
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}
```

The compiler error here is `borrow of moved value: s`.

What happens at the end of `main`? If the `if` branch ran, `s` still owns its
resource, so the resource must be dropped when `s` goes out of scope. If the
`else` branch ran, the resource was moved into `takes_ownership` (and dropped
when `some_string` went out of scope there), so it must not be dropped again.
Rust handles this by keeping a hidden *drop flag* that records at run time
whether `s` still owns a resource, and drops the resource only if it does.

## `if` Expressions

In Rust, `if` is an expression: it produces a value, so you can use it on the
right-hand side of a `let`. Here, whichever branch runs creates a new `String`
and ownership of it is moved to `greeting`.

```rv
fn main() {
    let formal = true;
    let greeting = if formal {
        String::from("Good morning")
    } else {
        String::from("hi")
    };
    println!("{}", greeting);
}
```

This code prints `Good morning`.

Both branches give `greeting` a resource, so after the `if` expression
`greeting` is certain to own one, and that resource is dropped when `greeting`
goes out of scope at the end of `main`.

## `match`

A `match` expression compares a value against a list of *patterns* and runs the
first arm whose pattern matches. The examples below match on an
`Option<String>`. A value of this type is either `Some(...)`, holding a
`String`, or `None`, holding nothing.

### Matching on a Reference

If we match on a *reference* to the `Option`, written `&name`, then the
variable `n` bound by the pattern `Some(n)` is also a reference: it has type
`&String` and borrows the `String` inside `name`. Nothing is moved, so `name`
still owns its resource after the `match`, and we can keep using it.

```rv
fn main() {
    let name = Some(String::from("Ferris"));
    match &name {
        Some(n) => println!("hello, {}", n),
        None => println!("no name"),
    }
    println!("{:?}", name);
}
```

This code prints `hello, Ferris` on one line and `Some("Ferris")` on the next.
(The `{:?}` placeholder asks `println!` for a debugging representation, which
`Option` provides.)

### Matching by Value

If we match on `name` itself instead, then `n` binds the `String` by value:
ownership of the `String` is moved out of `name` and into `n`. The arm's body
is a block, and `n` goes out of scope at the end of that block, so the `String`
is dropped there, before the `match` ends.

```rv
fn main() {
    let name = Some(String::from("Ferris"));
    match name {
        Some(n) => {
            println!("hello, {}", n);
        }
        None => println!("no name"),
    }
}
```

This code prints `hello, Ferris`.

As with `if`, only one arm runs, so after the `match` the `String` *might*
have been moved out of `name`, and `name` can no longer be used. If the `None`
arm ran, nothing was moved, but `name` holds no `String` either, so there is
nothing left to drop when `name` goes out of scope at the end of `main`.
