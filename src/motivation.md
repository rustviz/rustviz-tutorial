# A Visual Introduction to Rust

This is a short introduction to the Rust programming language, intended for
programmers with some C or C++ experience. 

The tutorial makes use of [RustViz](https://github.com/rustviz/rustviz),
an interactive visualization system for Rust code being developed by
[FP Lab](https://fplab.mplse.org/). You can also try the snippets in
this tutorial in the [RustViz Playground](https://rustviz.github.io/).

# Motivation

C and C++ are popular languages for low-level systems programming because they 
give programmers direct control over memory allocation and deallocation.
However, these languages are not *memory safe*. Programs can crash or exhibit
security vulnerabilities due to memory-related bugs, such as use-after-free
bugs. Programs can also have memory leaks, which occur when memory is not freed
even when it is no longer needed.

Most other popular languages are memory safe, but this comes at the cost of
run-time performance: they rely on a run-time garbage collector to automatically
free memory when it is no longer being used. The overhead of garbage collection
can be significant for performance critical tasks.

Rust is designed to be the best of both worlds: it is memory safe without the
need for a garbage collector. Instead, it relies on a compile-time ownership and
borrowing system to automatically determine when memory can be freed. 

The trade-off is that Rust's ownership and borrowing system can be difficult to
learn. The purpose of this tutorial is to help you learn Rust's ownership and
borrowing system visually.

For example, this tutorial will help you understand code like the following.
Hover over the different components of the visualization to see explanations.
Don't worry yet about what is going on in detail—these concepts will be
explained in this tutorial.

```rv
fn main() {
    let mut s = String::from("hello");

    let r1 = &s;
    let r2 = &s;
    compare_strings(r1, r2);

    let r3 = &mut s;
    clear_string(r3);
}

fn compare_strings(s1: &String, s2: &String) -> bool { // rustviz: hide
    *s1 == *s2
}

fn clear_string(s3: &mut String) { // rustviz: hide
    s3.clear();
}
```

