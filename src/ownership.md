# Ownership

More interesting data structure: heap-allocated string 

```rust
{{#rustdoc_include assets/code_examples/string_from_print/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="string_from_print code_panel" data="assets/code_examples/string_from_print/vis_code.svg"></object>
  <object type="image/svg+xml" class="string_from_print tl_panel" data="assets/code_examples/string_from_print/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('string_from_print')"></object>
</div>

String::from allocates a string in the heap given a string literal (string literals themselves have a more primitive type, &str, that is not important here.)

When we allocate in the heap, we have to also think about de-allocation. In C/C++, this is done manually with a free or delete. Rust instead uses a system of 
ownership to determine when deallocation occurs. In short, *resources* like heap allocated strings are *dropped* (Rust's word for deallocation) when the 
ownership's lifetime ends. 

In this case, the ownership of the heap allocated resource is moved from String::from to x. The println! macro does not affect ownership. 
It is then dropped at the end of the function. You can see this happening by hovering over the elements of the visualization on the right. 

# Moves

Ownership of a resource can change in several ways.

## Binding
```rust
{{#rustdoc_include assets/code_examples/string_from_move_print/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="string_from_move_print code_panel" data="assets/code_examples/string_from_move_print/vis_code.svg"></object>
  <object type="image/svg+xml" class="string_from_move_print tl_panel" data="assets/code_examples/string_from_move_print/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('string_from_move_print')"></object>
</div>

Ownership of the string resource moves from x to y. Because x no longer owns its resource,
we can no longer access it through x. For example, the following generates an error:

```rust
fn main() {
    let x = String::from("hello");
    let y = x;
    println!(x); // error: x does not own its resource
}
```

At the end of the function, both x and y go out of scope (their lifetimes have ended). 
x does not own a resource anymore, so nothing special happens.
y does own a resource, so its resource is dropped.

## Function Call

Ownership can also be moved into a function. For example:

```rust
fn main() {
    let s = String::from("hello");
    takes_ownership(s);
    // println!("{}", s); // <- won't compile if added
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}
```

Here, ownership of the string resource in main is moved to the take_ownership function. 
Therefore, when s goes out of scope, it no longer owns its resource, so the resource is not dropped.

The some_string variable in the takes_ownership function acquires ownership of a String resource when the function is called.
It prints this string, which does not affect ownership. 
Therefore, some_string has ownership of its resource when it goes out of scope, and the resource is therefore dropped at that point. 

Hover over the messages in the visualization to be sure you understand.

## Return

