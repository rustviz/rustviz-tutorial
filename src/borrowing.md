# Borrowing

## Immutable Borrows

```rust
{{#rustdoc_include assets/code_examples/immutable_borrow/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="immutable_borrow code_panel" data="assets/code_examples/immutable_borrow/vis_code.svg"></object>
  <object type="image/svg+xml" class="immutable_borrow tl_panel" data="assets/code_examples/immutable_borrow/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('immutable_borrow')"></object>
</div>

Idea here: x is the owner of a string, it is borrowed by f but x remains the owner
and can continue to use the resource after the call to f. the string is dropped at
the end of main()

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

