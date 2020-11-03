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
  println("{}", some_string);
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

You can take multiple immutable borrows at the same time:

```rust
{{#rustdoc_include assets/code_examples/multiple_immutable_borrow/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="multiple_immutable_borrow code_panel" data="assets/code_examples/multiple_immutable_borrow/vis_code.svg"></object>
  <object type="image/svg+xml" class="multiple_immutable_borrow tl_panel" data="assets/code_examples/multiple_immutable_borrow/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('multiple_immutable_borrow')"></object>
</div>

### Mutation + Immutable Borrows

You can't mutate something when there is an immutable borrow alive. 

```rust
fn main() {
    let mut x = String::from("Hello");
    let y = &x;
    x.push_str(", world"); // NOT OK
    f(y) //TODO: Technically, push_str is mutably borrowing x's resource. We could do x = String::from("Hi") as an alternative
}

fn f(s : &String) {
    println!("Length: {}", s.len())
}
```

## Mutable Borrows

You can take a mutable borrow if you have a mutable resource. You can only mutate borrowed resources if you have a mutable borrow. 

```rust
{{#rustdoc_include assets/code_examples/mutable_borrow/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="mutable_borrow code_panel" data="assets/code_examples/mutable_borrow/vis_code.svg"></object>
  <object type="image/svg+xml" class="mutable_borrow tl_panel" data="assets/code_examples/mutable_borrow/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('mutable_borrow')"></object>
</div>

If there is a live mutable borrow, then it has unique access to the resource. The owner cannot mutate it: 

```rust 
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x;
    x.push_str(", world"); // NOT OK, y is still live
    world(y) //TODO: Technically, push_str is mutably borrowing x's resource. We could do x = String::from("Hi") as an alternative
}

fn world(s : &mut String) {
    s.push_str(", world")
}
```

Nor can there be other borrows live, mutable or immutable:

```rust 
fn main() {
    let mut x = String::from("Hello");
    let y = &mut x;
    let z = &x; // NOT OK, y is alive
    world(y); 
    f(z)
}

fn f(s : &String) {
    println!("Length: {}", s.len())
}

fn world(s : &mut String) {
    s.push_str(", world")
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
    println!("{}", x)
}

fn world(s : &mut String) {
    String::push_str(s, ", world");
    s.push_str(", world")
    s.push_str("...")
}
```

(Do we want to say that mutable references are themselves moved while immutable references are copied?)
println! implicitly takes a reference

