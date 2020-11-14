# Rust Basics

## Main Function
In every Rust program, the `main` function executes first:
```rust
fn main() {
    // code here will run first
}
```

## Variables
In Rust, we use `let` bindings to introduce variables. Variables are *immutable*
or *mutable*.

### Immutable Variables
By default, variables are *immutable* in Rust. This means that once a value is
bound to the variable, the binding cannot be changed. We use `let` bindings to
introduce immutable variables as follows:
```rust
{{#rustdoc_include assets/code_examples/immutable_variable/source.rs}}
```

In this example, we introduce a variable `x` of type `i32` (a 32-bit signed
integer type) and bind the value `5` to it. 

You cannot assign to an immutable variable. So the following example causes a
compiler error:
```rust
fn main() {
    let x = 5;
    x = 6; // ERROR
}
```

The compiler error here is `cannot assign twice to immutable variable x`.

### Mutable Variables
If you want to be able to assign to a variable, it must be marked as *mutable*
with `let mut`:
```rust
{{#rustdoc_include assets/code_examples/mutable_variables/source.rs}}
```

## Copies
For simple types like integers, we can freely copy values. For example, we can
bind the value `5` to `x` and then bind `y` with a copy of `x`:
```rust
{{#rustdoc_include assets/code_examples/copy/source.rs}}
```

Note that copying occurs only for simple types like `i32` or other types that
have been marked as copyable—we will discuss how more interesting data
structures that are not marked as copyable behave differently in later sections
of the tutorial.

## Functions
Besides `main`, we can define additional functions. In the following example, we
define a function called `plus_one` which takes an `i32` as input and returns an
`i32` value that is one more than the input:
```rust
{{#rustdoc_include assets/code_examples/function/source.rs}}
```

Notice how there is no explicit return. In Rust, if the last expression in the
function body does not end in a semicolon, it is the return value. (Rust also
has a `return` keyword, but we do not use it here.)

## Printing to the Terminal
In Rust, we can print to the terminal using `println!`:
```rust
fn main() {
    println!("Hello, world!")
}
```
This code prints `Hello, world!` to the terminal, followed by a newline
character.

We can also use curly brackets in the input string of `println!` as a
placeholder for certain values:
```rust
{{#rustdoc_include assets/code_examples/printing/source.rs}}
```

This prints `x = 1 and y = 2`.

Note that the `!` at the end of `println!` indicates that it is a *macro*, not a
function. It behaves slightly differently from normal functions, but you do not
need to worry about that for this tutorial. 