# Motivation

C and C++ are not memory safe, meaning that programs can crash or have security
vulnerabilities due to memory-related bugs. They can also have memory leaks,
which occur when memory is not freed. 

Many other languages are memory safe, but at the cost of run-time
performance—they use a garbage collector to automatically free memory when it is
no longer being used.

Rust is memory safe, but it does not use a garbage collector, so it has
performance characteristics similar to C or C++.

## What is this tutorial?

This is a short introductory tutorial to Rust for programmers with C or C++
experience. Rather than just describing Rust's ownership and borrowing system
verbally, we use an interactive visualization system being developed by FP Lab 
to show how ownership changes and borrows propagate through the example code.

For example, this book will help you understand code like the following. Hover
over the different components of the visualization to see explanations. Don't
worry yet about what is going on—these concepts will be explained in this
reading.

```rust
{{#rustdoc_include assets/code_examples/hatra2/source.rs}}
```
<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: none;">
  <object type="image/svg+xml" class="hatra2 code_panel" data="assets/code_examples/hatra2/vis_code.svg"></object>
  <object type="image/svg+xml" class="hatra2 tl_panel" data="assets/code_examples/hatra2/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('hatra2')"></object>
</div>

Click the next button on the right of the page to continue. 