# Borrowing

In the previous section, we learned that each resource has a unique owner.
Ownership can be moved—for example, into a function.

In many situations, however, we do not want to permanently move a resource into
a function. Instead, we want to retain ownership but allow the function to temporarily 
access the resource while it executes.

We could accomplish this by having each function agree to return resources of this 
sort. For
example, `take_and_return_ownership` below takes ownership of a string
resource and returns ownership of that exact same resource. The caller, `main`,
assigns the returned resource to the same variable, `s`. 

```rv
fn take_and_return_ownership(some_string: String) -> String {
    println!("{}", some_string);
    some_string
}
  
fn main() {
    let mut s = String::from("hello");
    s = take_and_return_ownership(s);
    println!("{}", s);   // OK
}
```

This code prints `hello` twice.

The type of
`take_and_return_ownership` does not guarantee that the returned resource is the
same as the provided resource. Instead, the programmer has to trust that it returns 
the same resource.

As code becomes more complex, this pattern of returning all of the provided
resources explicitly becomes both syntactically and semantically unwieldy.

Fortunately, Rust offers a powerful solution: passing in arguments via a
reference. Taking a reference does *not* change the owner of a resource. 
Instead, the reference simply *borrows* access to the resource temporarily.
Rust's *borrow checker* requires that references to resources do not outlive 
their owner, to avoid the possibility of there being references to resources 
that the ownership system has decided can be dropped.

There are two kinds of borrows in Rust, *immutable borrows* and *mutable
borrows*. These differ in how much access to the resource they provide. 

## Immutable Borrows

In the following example, we define a function, `f`, that takes an *immutable
reference* to a `String`, which has type `&String`, as input. It then de-references
the immutable reference, written `*s`, in order to print it.

When the `main` function calls `f`, it must provide a reference to a `String` as
an argument. Here, we do so by taking a reference to the let-bound variable `x`
on Line 3, written `&x`. Taking a reference does **not** cause a change in
ownership, so `x` still owns the string resource in the remainder of `main`
and it can, for example, print `x` on Line 4. The resource will be dropped when
`x` goes out of scope at the end of `main` as we discussed previously. Because `f`
takes a reference, it is only *borrowing* access to the resource that the
reference points to. It does not need to explicitly return the resource because
it does not own it. Rust knows that the borrow does not outlive the owner 
because the borrow is no longer accessible after `f` returns.
```rv
fn main() {
    let x = String::from("hello");
    f(&x); 
    println!("{}", x);
}

fn f(s: &String) {
    println!("{}", *s);
}
```

This code prints `hello` twice.

Note: you do not actually need to dereference `s` to pass it to `println!` in Rust: 
it is a macro, so it will automatically dereference or borrow as needed 
to ensure that a move is not needed. Indeed, Rust does a lot of implicit 
borrowing and dereferencing to make its syntax simple, as we will see in other examples 
below.

Methods of the `String` type, like `len` for computing the length, typically
take their arguments by reference. You can call a method explicitly with a
reference, e.g. `String::len(&s)`. As shorthand, you can use dot notation to
call a method, e.g. `s.len()`. This implicitly takes a reference to `s`. 

```rv
fn main() {
    let s = String::from("hello");
    let len1 = String::len(&s);
    let len2 = s.len(); // shorthand for the above
    println!("len1 = {} = len2 = {}", len1, len2);
}
```

This code prints `len1 = 5 = len2 = 5`.

You can keep multiple immutable borrows live at the same time, e.g. `y` and `z`
in the following example are both live as shown in the visualization. For this
reason, immutable borrows are also sometimes called shared borrows: each
immutable reference shares access to the resource with the owner and with any
other immutable references that might be live.

```rv
fn main() {
    let x = String::from("hello");
    let y = &x;
    let z = &x;
    f(y, z);
}

fn f(s1: &String, s2: &String) {
    println!("{} and {}", s1, s2);
}
```

This code prints `hello and hello`.

Ownership of a resource cannot be moved while it is borrowed. For example, the
following is erroneous:

```rust
fn main() {
  let s = String::from("hello");
  let x = &s;
  let s2 = s; // ERROR: cannot move s while a borrow is live
  println!("{}", String::len(x));
}
```

The compiler error here is: `cannot move out of s because it is borrowed`.

## Mutable Borrows

Unlike immutable borrows, Rust's mutable borrows allow you to mutate the
borrowed resource. In the example below, we push (copy) the contents of a `String` `s2` 
to the end of the heap-allocated `String` `s1` twice, first by explictly calling
the `String::push_str` method, and then using the equivalent shorthand method
call syntax. In both cases, the method takes a *mutable reference* to `s1`,
written explicitly `&mut s1`.

```rv 
fn main() { 
    let mut s1 = String::from("Hello");
    let s2 = String::from(", world");
    String::push_str(&mut s1, &s2); 
    s1.push_str(&s2); // shorthand for the above
    println!("{}", s1); // prints "Hello, world, world"
}
```

This code prints `Hello, world, world`.

Code that does a lot of mutation is notoriously difficult to reason about, so in
Rust, mutation is much more carefully controlled than in other imperative
languages.

First, you can only take a mutable borrow from a mutable variable, i.e. one 
bound using `let mut` like `s1` in the example above. Immutability is the
default in Rust because it is considered easier to reason about.

Second, mutable borrows are unique—you cannot take a borrow, mutable or
immutable, if any mutable borrow is live. This means that you can be certain
that no other code will be mutating a resource when you have mutably borrowed it.
For this reason, mutable borrows are also sometimes called *unique borrows*.

For example, the following code is erroneous because a mutable borrow, `y`, is
live.

```rust
fn main() {
  let mut x = String::from("hello");
  let y = &mut x;
  f(&x); // ERROR: y is still live
  String::push_str(y, ", world");
}

fn f(x: &String) {
  println!("{}", x);
}
```
The compiler error here is: `cannot borrow x as immutable because it is also
borrowed as mutable`.

The following code is erroneous for the same reason.

```rust 
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x; 
    let z = &mut x; // ERROR: y is still live
    String::push_str(y, ", world");
    String::push_str(z, ", friend");
    println!("{}", x);
}
```
The compiler error here is: `cannot borrow x as mutable more than once at a
time`.

### Optional: Threading in Rust

In the example above, the two calls to `push_str` are sequenced. However, if we
wanted to execute them concurrently, we could do so by spawning a thread as
follows. Here, `|| { e }` is Rust's notation for an anonymous function taking
unit input.

```rust 
use std::thread;

fn main() {
    let mut x = String::from("Hello");
    let y = &mut x; 
    let z = &mut x; // NOT OK: y is still live
    thread::spawn(|| { String::push_str(y, ", world"); });
    String::push_str(z, ", friend");
    println!("{}", x);
}
```

If the borrow checker did not stop us, this program would have a race
condition—it could print either `Hello, world, friend` or `Hello, friend, world`
depending on the interleaving of the main thread and the newly spawned thread.
By tightly controlling mutation, Rust prevents races mediated by shared mutable state.

## Non-Lexical Lifetimes

Above, we use the phrase "live borrow". A borrow is *live* if it is in scope and
there remain future uses of the borrow. A borrow dies as soon it is no longer
needed. So the following code works, even though there are two mutable borrows
in the same scope:

```rv
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x;
    world(y);
    let z = &mut x; // OK, because y's lifetime has ended (last use was on previous line)
    world(z);
    x.push_str("!!"); // Also OK, because y and z's lifetimes have ended
    println!("{}", x);
}

fn world(s: &mut String) {
    s.push_str(", world");
}
```

This code prints `Hello, world, world!!`.
## Reborrowing

Immutable references are copyable (`&T` implements the `Copy` trait), so passing
one to a function simply copies it. Mutable references are *not* copyable,
because a mutable borrow must be unique. So you might expect that passing a
mutable reference `r` to a function would move it, leaving `r` unusable
afterwards. That is not what happens in the following example, which calls
`add_world(r)` twice.

```rv
fn main() {
    let mut s = String::from("hello");
    let r = &mut s;
    add_world(r);
    add_world(r);
    println!("{}", s);
}

fn add_world(t: &mut String) {
    t.push_str(", world");
}
```

This code prints `hello, world, world`.

Instead of moving `r`, Rust *reborrows* through it: `add_world(r)` is
treated as `add_world(&mut *r)`, i.e. a new mutable borrow of the `String`
that `r` points to. While that reborrow is live, `r` cannot be used. When
`add_world` returns, the reborrow ends and `r` can be used again, so the second
call is fine. Hover over the calls on Lines 4 and 5 to see this.

You can also write reborrows explicitly. Here, `*r` is the `String` that `r`
points to, so `&mut *r` mutably borrows it again through `r`, and `&*r`
immutably borrows it through `r`.

```rv
fn main() {
    let mut s = String::from("hello");
    let r = &mut s;
    let r2 = &mut *r;
    r2.push_str("!");
    let r3 = &*r;
    println!("{}", r3);
    r.push_str("?");
    println!("{}", s);
}
```

This code prints `hello!` on one line and `hello!?` on the next.

The rules are the same as for borrowing from an owner. While the mutable
reborrow `r2` is live, `r` cannot be used at all. While the immutable reborrow
`r3` is live, `r` can only be used to read. Both reborrows end at their last
use (Lines 5 and 7), so `r` can write again on Line 8. After that, `r` is no
longer used, so its borrow of `s` ends and `s` can be printed on Line 9.

A method can also return a reborrow. In the example below (structs and
methods are covered in the optional section on structures), `name` takes an
immutable reference to a `Greeter`, written `&self`, and returns a reference to
its `s` field, written `&self.s`. Nothing is moved or copied out of `g`.

```rv
struct Greeter {
    s: String,
}

impl Greeter {
    fn name(&self) -> &String {
        &self.s
    }
}

fn main() {
    let g = Greeter { s: String::from("Ferris") };
    let n = g.name();
    println!("{}", n);
}
```

This code prints `Ferris`.

The signature `fn name(&self) -> &String` tells Rust that the returned
reference borrows from `self`. So `g` stays immutably borrowed for as long as
`n` is live, which here is until its last use on Line 14. `g` still owns the
`Greeter` (including its `String`), which is dropped when `g` goes out of
scope at the end of `main`.
