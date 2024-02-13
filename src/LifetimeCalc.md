# Reference Lifetimes

In the section on [Borrowing](./borrowing.md), we learned that taking a reference does *not* change the owner of a resource. 
Instead, the reference simply *borrows* access to the resource temporarily.
Rust's *borrow checker* requires that references to resources do not outlive 
their owner, to avoid the possibility of there being references to resources 
that the ownership system has decided can be dropped.

## Named Lifetimes

How does Rust reason about the lifetime of a reference, to ensure that the reference
does not outlive the owner? Implicitly, each reference type has an associated **lifetime**. 
This lifetime can be given an explicit name in the type. 
For example, `&'a int` is the type of a reference to an integer with named lifetime `'a` (pronounced ''tick a'' or ''alpha'').
Rust allows you to elide lifetime names in most, but not all, situations, as we will discuss below.

The borrow checker generates constraints on named lifetimes. 
These constraints can be concrete, e.g. a range of lines within a function during which the borrow must be
live. They can also be inequalities between named lifetimes, which specify 
containment relationships, e.g. that lifetime `'a` must be contained within lifetime `'b`.
The borrow checker then checks that there are no inconsistent constraints, reporting an error if there are.

For example, in the following code we explicitly write the name of the lifetime for `x`, calling it `'a`:

```rust
1 fn f() {
2  let s = String::from("hello");
3  let x : &'a String = &s;
4  let y = 5;
5  println!("{}", &x);
6  println!("{}, s);
7 }
```

The borrow checker first generates the constraint that this borrow must not outlive the owner, `s`, which 
is in scope from Lines 2 to 7 (without a change in ownership):
```
'a < [#2, #7]
```

In addition, due to the non-lexical lifetime analysis, we know that the lifetime of that reference must be
at least the time between reference creation and its last usage on Line 5:

```
'a >= [#3, #5]
```

These two constraints are not inconsistent with one another, so there is no borrow checker error to be reported here.

On the other hand, consider the situation where we attempt to return a reference to a locally owned resource from a function

```rust
1 fn f() {
2  let x = String::from("hello");
3  let y : &'a String = &x;
4  y
5 }
```

Here, we generate the constraint that the borrow must not outlive the owner, `x`, which is in scope from Lines 2 to 5 (without a change in ownership):
```
'a < [#2, #5]
```
However, since the reference is being returned from the function, we know its lifetime must extend past the end of the function, which we can write as:
```
'a > #5
```
These two constraints are inconsistent with one another, so the borrow checker reports an error.

## Function Lifetime Parameters
In addition to lifetime parameters on references, functions can also have generic lifetime parameters. 
Let's look at a simple function that takes two `i32` references and returns the reference to the larger quantity. Function `max` has an explicit lifetime parameter `'a`.

```rust
fn max<'a>(x: &'a i32, y: &'a i32) -> &'a i32{
    if x >= y {
        x
    }
    else {
        y
    }
}
```

Here is an example call site for the `max` function (with lifetimes explicitly annotated):

```rust
fn main(){
    let a = 10;
    let b = 6;
    let r: &'r i32;
    {
        let x: &'x i32 = &a;
        let y: &'y i32 = &b;
        r = max(x,y);
    }
    println!("r is {}",r);
}
```

Notice that we did not need to explicitly pass in the lifetime parameter `'a` when calling `max`. Instead, this parameter is inferred based on the arguments and the binding of the returned reference, which imply lifetime inclusion constraints (that one lifetime must necessarily include another in time for the code to work correctly). These constraints for each of these are visualized below:

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="lifetime_func_max code_panel" data="assets/code_examples/lifetime_func_max/vis_code.svg"></object>
  <object type="image/svg+xml" class="lifetime_func_max tl_panel" data="assets/code_examples/lifetime_func_max/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('lifetime_func_max')"></object>
</div>

We can perceive lifetime inclusion similar as subtyping. For instance, the provided argument `x` in the function call `max` is a reference with lifetime  `'x`. In the signature of `max`, the corresponding parameter has type `&'a i32`, so we generate the constraint that `'x` must be included in `'a`, written `'x <= 'a` on the top-right of the diagram above and visualized below (hover on the constraint to see the corresponding segment of the visualization). Since we independently have bounds on the lifetime `'x` due to its use in `main` and Rust's non-lexical lifetimes system, we know that `'a` must be inferred to be at least this long.

Similarly, the provided argument `y` has type `&'y i32` and is being passed into to an argument with type `&'a i32` so we generate the lifetime inclusion constraint `'y <= 'a`. In this case, `'y` is smaller than `'x` so our inferred bound on `'a` does not need to get bigger -- hover over the diagram to make sure you understand.

Finally, the value returned by the call to `max` is bound to `r`, which has type `&'r i32`. Since the return type of `max` is `&'a i32`, we generate our final constraint, `'r <= 'a`. Again, we independently know that `'r` must live until Line 10, so this enlarges our bound on `'a`. 

Hover over the diagram to see how we compute the final bound by taking into account all three of these lifetime constraints:
```
'a >= 'x
'a >= 'y
'a >= 'r
```
The lifetime that is inferred must be at least as large as the largest of these three lifetimes. By approximating lifetimes with line numbers in the function `main`, we get the equivalent constraint set for `'a`:
```
'a >= [#6, #8]
'a >= [#7, #8]
'a >= [#4, #10]
```
We could infer any lifetime that does not violate these constraints, but we would prefer to infer tight lifetimes to avoid potential errors that relate to overlapping lifetimes, so we ultimately choose the smallest valid lifetime for `'a`, that is `'a >= [#4, #10]`. Hover through the diagram to make sure you understand!

## Lifetime Elision 

TODO: what is lifetime elision (one or two examples)

To make programmers' life easier in using Rust, Rust allows certain lifetime annotations to be elided. The reason is that the borrow checker can figure out the lifetime constraint itself without ambiguity.

For example:
```rust
fn print(s: &str);                                      // elided
fn print<'a>(s: &'a str);                               // expanded
```
The `print` function takes in a reference and returns nothing. Therefore, there is no need to worry about returning invalidated reference. In this case, we don't need to annotated the lifetime explicitly for `s: &str`.

When the function does return a reference, lifetime elision rule may still be applicable. For instance:
```rust
fn substr(s: &str, until: usize) -> &str;               // elided
fn substr<'a>(s: &'a str, until: usize) -> &'a str;     // expanded
```
Even though `substr` returns a reference, but it only takes in one input reference `s: &str`. The borrow checker is able to infer that the lifetime of returned reference `&str` must be constrained by `s: &str`. Hence, the programmer can omit the lifetime annotation and let the borrow checker to figure it out.

More details: https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html

## Type Lifetime Parameters

A `struct` must have explicit lifetime parameter annotations if it contains references, because there is no clear way for Rust to infer appropriate lifetime parameters given only a type definition (no constraints are generated). 

For example, in the definition below, both references in the struct share a lifetime:
```rust
struct Book<'a> {
    name: &'a String,
    descr: &'a String,
    serial_num: i32
}
```
However, you could also have two different lifetimes, one for each reference:
```rust
struct Book<'a, 'b> {
    name: &'a String,
    descr: &'b String,
    serial_num: i32
}
```




TODO: refine this    
Here we define a `Book` struct that contains an immutable reference to a `String`. `'a` means that if the lifetime of `Book` is `'a`, then the lifetime of `name : &'a String` will be at least `'a`. Therefore, any instance of `Book` will never outlive its contained reference `name`.



```rust
struct Book<'a>{
    name: &'a String,
    descr: &'a String,
    serial_num: i32
}

fn main(){
    let mut name = String::from("The Rust Book");
    let descr_str = String::from("New Edition of the Rust Book.");
    let serial_num = 1140987;
    {
        let descr_ref = &descr_str;
        let rust_book =  Book { name: &name, descr: descr_ref, serial_num: serial_num };
        println!("The name of the book is {}", rust_book.name);
    }
    name = String::from("Behind Borrow Checker");
    println!("New name: {}",name);
}

```

First and foremost, we need to calculate the lifetime of each variable. It suffices to just look at line numbers and scoping curly brackets:

| Variable     | Lifetime |
|:------------:|:--------:|
| `name`       | [#8, #18] |
| `serial_num` | [#10, #18] |
| `rust_book`  | [#10, #12] |

Note that since `rust_book` is in an inner scope, it will be destructed when the scope ends. To calculate lifetime parameter on the struct default constructor, we list all constraints to the lifetime parameter `'a`.

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="lifetime_struct code_panel" data="assets/code_examples/lifetime_struct/vis_code.svg"></object>
  <object type="image/svg+xml" class="lifetime_struct tl_panel" data="assets/code_examples/lifetime_struct/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('lifetime_struct')"></object>
</div>


Since `&name` is a temporary variable created just to be passed on line 10, its lifetime will be limited on line 10 (starts on line 10 and ends on line 10).

Therefore, `'a` inside the `impl` block will cover lifetime of `rust_book` and `&name` (`serial_num` has nothing to do as it's not annotated by `'a`). So, `'a` = [#12, #15].




##### About reference passed on the fly

You may question why `&name` is only live on line 10. We could imagine the borrow checker will create a reference to `name` and pass that reference to the function, and everything is happening on a single line:

```rust
 let tmp = &name; let rust_book = Book::new(tmp, serial_num); // both happens on line 10
 // tmp's lifetime is end here
```

As [NLL lifetime](https://stackoverflow.com/questions/50251487/what-are-non-lexical-lifetimes) defines a reference's lifetime ends after its last usage, `tmp` is created on line 10 and also ended on the same line. We will treat lifetime of references created on the fly in this way in the following tutorial.




## Conclusion
In this tutorial, we showed you how to understand how lifetime parameter works and how to properly calculate the scope of each lifetime parameter, for the purpose of grasping the rationale behind the Rust borrow checker. Through Rustviz visualization tool, we can illustrate how borrow checker generates constraints for lifetime parameter in a more vivid way. If you found this kind of visualization useful, welcome to download Rustviz and create your own visualization on Rust lifetime parameter!