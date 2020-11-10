# Ownership

In the previous section, we considered only simple values, like integers. 
However, in real-world programs, we work with more complex data structures that allocate
resources on the heap. When we allocate resources, we need a strategy for
de-allocating these resources. Most programming languages use one of two
strategies:

1. Manual Deallocation (C, C++): The programmer is responsible for explicitly
deallocating memory, e.g. using `free` in C or `delete` in C++. 
This is performant but can result in critical issues such as
use-after-free bugs, double-free bugs, and memory leaks. 

2. Garbage Collection (OCaml, Java, Python): The programmer does not have to
explicitly deallocate memory. Instead, a *garbage collector* frees (deallocates)
memory when it knows no further references to it remain. 
This prevents memory safety bugs. However, the garbage collector 
creates additional run-time performance overhead, because it needs to dynamically
determine whether there are any remaining references.

Rust uses a third strategy—a static (i.e. compile-time) ownership system.
Because this is a purely compile-time mechanism, it achieves achieves memory
safety without the performance overhead of garbage collection. 

The key idea is that each resource in memory has a unique *owner*. When the
owner dies, e.g. by going out of scope, the resource is deallocated (in Rust,
we say that the resource is *dropped*).

## Heap-Allocated Strings

For example, heap-allocated strings are managed by Rust's ownership system.
Consider the following example, which constructs a heap-allocated string and
prints it out.

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="string_from_print code_panel" data="assets/code_examples/string_from_print/vis_code.svg"></object>
  <object type="image/svg+xml" class="string_from_print tl_panel" data="assets/code_examples/string_from_print/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('string_from_print')"></object>
</div>

This code prints `hello`.

The `String::from` function allocates a string on the heap. The string is
initialized by providing a string literal (string literals themselves have a
more primitive type, `&str`, that is not important here.) Ownership of this
string resource is *moved* to the variable `s` (of type `String`) when
`String::from` returns on Line 2.

The `println!` macro does not cause a change in ownership (we say more about
`println!` later, but omit it from the visualization until then).

At the end of the `main` function, the variable `s` goes out of scope. It has
ownership of the string resource, so Rust will *drop*, i.e. deallocate, the
resource at this point. We do not need an explicit `free` or `delete` like we
would in C or C++, nor is there any run-time garbage collection overhead. 

Hover over the lines and arrows in the visualization next to the code example
above to see a description of the events that occur on each line of code.

## Moves

In the example above, we saw that ownership of the heap-allocated string moved
to the caller when `String::from` returned. This is one of several situations
where ownership of a resource can move. We will now consider each situation in
more detail. 

### Binding
Ownership can be moved when initializing a binding with a variable. 

In the following example, we define a variable `x` that owns a `String` resource. 
Then, we define another variable, `y`, initialized with `x`. This causes
ownership of the string resource to be moved from `x` to `y`. 

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="string_from_move_print code_panel" data="assets/code_examples/string_from_move_print/vis_code.svg"></object>
  <object type="image/svg+xml" class="string_from_move_print tl_panel" data="assets/code_examples/string_from_move_print/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('string_from_move_print')"></object>
</div>

This code prints `hello`.

At the end of the function, both `x` and `y` go out of scope (their lifetimes
have ended). `x` does not own a resource anymore, so nothing special happens.
`y` does own a resource, so its resource is dropped. Hover over the
visualization to see how this works.

Each resource must have a unique owner, so `x` will no longer own the string
resource after the move. This means that it will no longer be possible to access
the resource through `x`. Think of it like handing a resource to another person:
you no longer have it in your hand once it has moved. For example, the following
generates a compiler error:

```rust
fn main() {
    let x = String::from("hello");
    let y = x;
    println!("{}", x) // ERROR: x does not own a resource
}
```
The compiler error says `borrow of moved value: x` (we will discuss what
*borrow* means in later sections.)

If we move to a variable that has a different scope, then you can see by
hovering over the visualization that the resource is dropped at the end of `y`'s
scope rather than at the end of `x`'s scope.

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="move_different_scope code_panel" data="assets/code_examples/move_different_scope/vis_code.svg"></object>
  <object type="image/svg+xml" class="move_different_scope tl_panel" data="assets/code_examples/move_different_scope/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('move_different_scope')"></object>
</div>

This code prints `hello` on one line and `Hello, world!` on the next.

### Assignment

Similarly, ownership can be moved by assignment to a mutable variable, e.g. `y`
in the following example.

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="move_assignment code_panel" data="assets/code_examples/move_assignment/vis_code.svg"></object>
  <object type="image/svg+xml" class="move_assignment tl_panel" data="assets/code_examples/move_assignment/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('move_assignment')"></object>
</div>

When `y` acquires ownership over `x`'s resource on Line 4, the resource it
previously acquired (on Line 3) no longer has an owner, so it is dropped.

### Function Call

Ownership can also be moved into a function when it is called. For example, 
ownership of the string resource in `main` is moved from `s` to the
`takes_ownership` function. Consequently, when `s` goes out of scope at the end
of `main`, there is no owned string resource to be dropped.

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="func_take_ownership code_panel" data="assets/code_examples/func_take_ownership/vis_code.svg"></object>
  <object type="image/svg+xml" class="func_take_ownership tl_panel" data="assets/code_examples/func_take_ownership/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('func_take_ownership')"></object>
</div>

This code prints `hello`.

From the perspective of `takes_ownership`, it can be assumed that the argument
variable `some_string` will receive ownership of a `String` resource from the
caller (each time it is called). The argument variable `some_string` goes out of
scope at the end of the function, so the resource that it owns is dropped at
that point.

Hover over the messages in the visualization to be sure you understand.

### Return

Finally, ownership can be returned from a function. 

In the following example, `f` allocates a string, `x`, and returns it to the
caller. Ownership is moved from `x` to the caller, so there is no owned resource
to be dropped at the end of `f`. Instead, the resource is dropped when the new
owner, `s`, goes out of scope at the end of `main`. (If the string were dropped
at the end of `f`, there would be a use-after-free bug in `main` on Line 3!)

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="move_func_return code_panel" data="assets/code_examples/move_func_return/vis_code.svg"></object>
  <object type="image/svg+xml" class="move_func_return tl_panel" data="assets/code_examples/move_func_return/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('move_func_return')"></object>
</div>

This code prints `hello`.