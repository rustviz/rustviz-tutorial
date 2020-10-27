# Borrowing

## Immutable Borrows

```rust
fn main() {
    let x = String::from("hello");
    let y = f(&x); 
    println!("{}", x);
}

fn f(s : &String) {
    println!("Length: {}", s.length()) // todo figure out length function
}
```

Idea here: x is the owner of a string, it is borrowed by f but x remains the owner
and can continue to use the resource after the call to f. the string is dropped at
the end of main()

You can take multiple immutable borrows at the same time:

```rust 
fn main() {
    let x = String::from("hello");
    let y = &x;
    let z = &x;
    println!("{}", x);
    f(y);
    f(z);
}

fn f(s : &String) {
    println!("Length: {}", s.length()) // todo figure out length function
}
```

### Mutation + Immutable Borrows

You can't mutate something when there is an immutable borrow alive. 

```rust
fn main() {
    let mut x = String::from("Hello");
    let y = &x;
    x.push_str(", world"); // NOT OK
    f(y);
}

fn f(s : &String) {
    println!("Length: {}", s.length()) // todo figure out length function
}
```

## Mutable Borrows

You can take a mutable borrow if you have a mutable resource. You can only mutate borrowed resources if you have a mutable borrow. 

```rust 
fn main() {
    let mut x = String::from("Hello");
    world(&mut x);
}

fn world(s : &mut String) {
    s.push_str(", world");
}```

If there is a live mutable borrow, then it has unique access to the resource. The owner cannot mutate it: 

```rust 
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x;
    x.push_str(", world"); // NOT OK, y is still alive
    world(y);
}

fn world(s : &mut String) {
    s.push_str(", world");
}```

Nor can there be other borrows alive, mutable or immutable:

```rust 
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x;
    let z = &x; // NOT OK, y is alive
    world(y);
    f(z);
}

fn f(s : &String) {
    println!("Length: {}", s.length());
}

fn world(s : &mut String) {
    s.push_str(", world");
    ...
}
```

TODO: something about why this restriction makes sense (don't want different borrows to be simultaneously accessing a mutable resource to prevent race conditions, reasoning more simply about mutation -- you know that
functions aren't mutating things unless you explicitly give them the unique mutable borrow, so you can reason 
functionally -- maybe include a case from mutable to immutable, but possibly too complicated)

## Non-Lexical Lifetimes

Above, we use the phrase "live borrow". A borrow is live if it is in scope and there remain future
uses of the borrow. A borrow dies once as soon it is no longer needed. So the following code works, 
even though there are two mutable borrows in the same scope:

(inspect the hover messages to see what's going on -- maybe say similar things above)

```rust 
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x;
    world(y);
    let z = &mut x; // OK, because y's lifetime has ended (last use was on previous line)
    world(z);
    x.push_str("!!"); // Also OK, because y and z's lifetimes have ended
}

fn world(s : &mut String) {
    s.push_str(", world");
}
```

(Do we want to say that mutable references are themselves moved while immutable references are copied?)

