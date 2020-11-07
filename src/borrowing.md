# Borrowing

In the previous section, we learned that each resource has a unique owner.
Ownership can be moved, for example into a function.

In many situations, however, we do not want to permanently move a resource into a function.
Instead, we want to allow the function to temporarily access the resource while it executes
but retain ownership over the resource after the function returns.

We could accomplish this by having each function return such resources. For example, 
`take_and_return_ownership` below takes ownership of a `String`
resource and returns ownership of that exact same resource.
The caller, `main`, binds the returned resource to the same variable, `s`, 
as it originally used (i.e. it shadows `s`).
(Technically, the type of `take_and_return_ownership` does not guarantee that 
the returned resource is the same as the provided resource.)

```rust
fn take_and_return_ownership(some_string : String) -> String {
  println!("{}", some_string);
  some_string
}

fn main() {
  let s = String::from("hello");
  let s = take_and_return_ownership(s);
  println!("{}", s);   // OK
}
```

As you write more complex code, this pattern of returning all of the provided resources explicitly becomes both syntactically and semantically unwieldy.

Fortunately, Rust offers a powerful solution: passing in arguments via a reference. 
Taking a reference does *not* change the owner of a resource. 
Instead, the reference simply borrows access to the resource temporarily.

There are two kinds of borrows in Rust, immutable borrows and mutable borrows. 
These differ in how much access to the resource they provide. 

## Immutable Borrows

In the following example, we define a function, `f`, that takes an immutable reference to a `String`, written `&String`, as input. It then dereferences the string, written `*s`, in order to print it.
(Actually, the `println!` macro will dereference `s` automatically if you just write `s`, but 
let's ignore that for now.)

When the `main` function calls `f`, it must provide a reference to a `String` as an argument,
here by taking a reference to the let-bound variable `x` on Line 3, written `&x`.
Taking a reference does **not** cause a change in ownership, so `x` still owns the string resource 
in the remainder of `main` and it can, for example, print `x` on Line 4. The resource will be dropped when `x` goes out of scope at the end `main` as we discussed previously. 
Because `f` takes a reference, it is only *borrowing* access to the resource that the reference points to. It does not need to explicitly return the resource because it does not own it. 

```rust
{{#rustdoc_include assets/code_examples/immutable_borrow/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="immutable_borrow code_panel" data="assets/code_examples/immutable_borrow/vis_code.svg"></object>
  <object type="image/svg+xml" class="immutable_borrow tl_panel" data="assets/code_examples/immutable_borrow/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('immutable_borrow')"></object>
</div>

Methods of the `String` type, like `len` for computing the length of the string,
typically take their arguments by reference. You can call a method explicitly with
a reference, e.g. `String::len(&s)`. As shorthand, you can use dot notation to 
call a method, e.g. `s.len()`. This implicitly takes a reference to `s`. 

```rust
fn main() {
  let s = String::from("hello");
  let len1 = String::len(&s);
  let len2 = s.len(); // shorthand for the above
  println!("len1 = {} = len2 = {}", len1, len2);
}
```

You can keep multiple immutable borrows live at the same time, e.g. `y` and `z`
in the following example are both alive as shown in the visualization. 
For this reason, immutable borrows are also sometimes called shared borrows: 
each immutable reference shares access to the resource with the owner 
and with any other immutable references that might be alive.

```rust
{{#rustdoc_include assets/code_examples/multiple_immutable_borrow/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="multiple_immutable_borrow code_panel" data="assets/code_examples/multiple_immutable_borrow/vis_code.svg"></object>
  <object type="image/svg+xml" class="multiple_immutable_borrow tl_panel" data="assets/code_examples/multiple_immutable_borrow/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('multiple_immutable_borrow')"></object>
</div>

Ownership of a resource cannot be moved while it is borrowed. For example, the following
is erroneous:

```rust
fn main() {
  let s = String::from("hello");
  let x = &s;
  let s2 = s; // ERROR: cannot move s while a borrow is live
  println!("{}", String::len(x));
}
```

## Mutable Borrows

Unlike immutable borrows, Rust's mutable borrows allow you to mutate the borrowed resource.
In the example below, we push the contents of a string `s2` 
to the end of the heap-allocated string `s1` twice, 
first by explictly calling the `String::push_str` method, and then using the equivalent shorthand method call syntax. 
In both cases, the method takes a *mutable* reference to `s1`, written explicitly `&mut s1`.

```rust
fn main() { 
  let mut s1 = String::from("Hello");
  let s2 = String::from(", world");
  String::push_str(&mut s1, &s2); 
  s1.push_str(&s2); // shorthand for the above
  println!("{}", s1); // prints "Hello, world, world"
}
```

Code that does a lot of mutation is notoriously difficult to reason about, so in Rust, 
mutation is much more carefully controlled than in other imperative languages.

First, you can only take a mutable borrow from a mutable variable, i.e. one 
bound using `let mut` like `s1` in the example above. Immutability is the default
in Rust because it is easier to reason about.

Second, mutable borrows are unique: you cannot take a borrow,
mutable or immutable, if any mutable borrow is live. 
This means that you can be certain that no other  
code will be mutating a resource when you have borrowed it.

For example, the following code is erroneous because a mutable borrow, `y`, is live.

```rust
fn main() {
  let mut x = String::from("hello");
  let y = &mut x;
  f(&x); // ERROR: y is still live
  String::push_str(y, ", world");
}

fn f(x : &String) {
  println!("{}", x);
}
```

Similarly, the following code is erroneous for the same reason.

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

### Optional: Threading in Rust

In the example above, the two calls to `push_str` are sequenced. However, if we wanted
to execute them concurrently, we could do so by spawning a thread as follows. Here,
`|| { e }` is Rust's notation for an anonymous function taking unit input.

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

If the borrow checker did not stop us, this program would have a race condition:
it could print either `Hello, world, friend` or `Hello, friend, world` depending
on the interleaving of the main thread and the newly spawned thread.

## Non-Lexical Lifetimes

Above, we use the phrase "live borrow". A borrow is live if it is in scope and there remain future
uses of the borrow. A borrow dies once as soon it is no longer needed. So the following code works, 
even though there are two mutable borrows in the same scope:

(inspect the hover messages to see what's going on -- maybe say similar things above)

```rust
{{#rustdoc_include assets/code_examples/nll_lexical_scope_different/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="nll_lexical_scope_different code_panel" data="assets/code_examples/nll_lexical_scope_different/vis_code.svg"></object>
  <object type="image/svg+xml" class="nll_lexical_scope_different tl_panel" data="assets/code_examples/nll_lexical_scope_different/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('nll_lexical_scope_different')"></object>
</div>