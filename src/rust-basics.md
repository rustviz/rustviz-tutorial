# Rust Basics

## Main Function
In every executuable Rust program, the `main` function contains the code that
will execute first:
```rust
fn main() {
    //code here will run first
}
```
## Variables
In Rust, we use `let` bindings to introduce variables. Variables are *mutable*
or *immutable*.

### Immutable Variables
By default, variables are *immutable* in Rust. This means that once a value is
bound to the variable, the binding cannot be changed. We use `let` bindings to
introduce immutable variables as follows:
```rust
fn main() {
    let x = 5;
}
```
In this example, we introduce a variable `x` of type `i32`(a 32-bit signed
integer type) and bind the value `5` to it. 

Since the binding cannot be changed for an immutable variable, the following
example causes a compiler error:
```rust
fn main() {
    let x = 5;
    x = 6; //ERROR
}
```

### Immutable Variables
Sometimes, we want to allow the binding of a variable to change. In order to do
this in Rust, we introduce *mutable* variables with `let mut` rather than `let`:
```rust
fn main() {
    let mut x = 5;
    x = 6; //OK
}
```

## Copies
For simple types like integers, assigning the value of a variable causes
the value to be copied. In this example, we bind the value `5` to `x` and then
assign the value of `x` to `y` which makes a copy `x`'s value:
```rust
fn main() {
    let x = 5;
    let y = x;
}
```

Note that this is only relevant for simple types like integers or other types
that have been marked as copyable—we'll discuss how more interesting data
structures behave differently in later sections of the tutorial.

## Functions
Besides `main`, we can define additional functions. In the following example, 
we define a function called `plus_one` which takes an `i32` as input returns an
`i32` with the value that is one more than the input:
```rust
fn main() {
    let six = plus_one(5);
}

fn five(x: i32) -> i32 {
    x + 1
}
```

Notice how there is no explicit return. In Rust, the last expression in the
function body is the return value. (Rust also has a `return` keyword, but we
do not use it here.)

## Printing to the Terminal
In Rust, we can print to the terminal using `println!`:
```rust
fn main() {
    println!("Hello, world!")
}
```

We can also use curly brackets in the input string of `println!` as a
placeholder for certain values:
```rust
fn main() {
    let x = 1;
    let y = 2;
    println!("x = {} and y = {}", x, y);
}
```

Note that `println!` is a *macro*, not a function. This means that it behaves
slightly differently from normal functions, but you do not need to worry about
that for this tutorial. 