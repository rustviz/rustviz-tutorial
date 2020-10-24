# RustViz Tutorial

This repo contains an introductory Rust tutorial which contains visualizations generated with [RustViz](https://github.com/fplab/rustviz). It is intended to be used in the Rust unit in EECS 490 at the University of Michigan.

## Usage
1. Install mdbook using `cargo install mdbook`
2. Navigate to the `rustviz-tutorial` directory and run `mdbook build`
3. Navigate to the `rustviz-tutorial/book` directory and run `python3 -m http.server`. You should be able to view the tutorial in your browser at http://localhost:8000/