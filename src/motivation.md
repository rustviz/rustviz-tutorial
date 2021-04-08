# A Visual Introduction to Rust

This is a short introduction to the Rust programming language, intended for
programmers with some C or C++ experience. 

The tutorial makes use of an interactive visualization system for Rust code
being developed by FP Lab. You should read this tutorial before completing 
the remaining questions, Q2 and Q3. 

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

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="hatra2 code_panel" data="assets/modified_examples/hatra2/vis_code.svg"></object>
  <object type="image/svg+xml" class="hatra2 tl_panel" data="assets/modified_examples/hatra2/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('hatra2')"></object>
</div>

## Research Disclosure

Your exercise answers and logs of your interactions with this tool might be used
for research purposes. All data used for research purposes will be anonymized:
your identity will not be connected to this data. If you wish to opt out, you
can contact the instructor (comar@umich.edu) at any time up to seven days after 
final grades have been issued. Opting out has no impact on your grade. 

Click the next button on the right of the page to continue.