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
fn f() {
  let s = String::from("hello");
  let x : &'a String = &s;
  let y = 5;
  println!("{}", &x);
  println!("{}, s);
}
```

The borrow checker first generates the constraint that this borrow must not outlive the owner, `s`, which 
is in scope from Lines 2 to 7 (without a change in ownership):
```
'a < [2, 7]
```

In addition, due to the non-lexical lifetime analysis, we know that the lifetime of that reference must be
at least the time between reference creation and its last usage on Line 5:

```
'a >= [3, 5]
```

These two constraints are not inconsistent with one another, so there is no borrow checker error to be reported here.

## Function Lifetime Parameters
Let's look a simple function that takes two references to `i32` and returns the reference to the bigger one. You've seen that on previous section, but this time all usages are correct:

```rust
fn max<'a>(x: &'a i32, y: &'a i32) -> &'a i32{
    if x >= y{
        x
    }
    else{
        y
    }
}
```

And a caller for `max`:

```rust
fn main(){
    let a = 10;
    let b = 6;
    let r: &i32;
    {
        let x: &i32 = &a;
        let y: &i32 = &b;
        r = max(x,y);
    }
    println!("r is {}",r);
}
```

To reason how borrow checker calculates `'a` of `max`, we need to first identify lifetimes of involved variables, `r`, `x` and `y`. `x` and `y` are limited to the inner scope, so lifetime of `x` is from line 6 to line 9, denoted as [#6,#9], and y is alive for [#7,#9] (for line numbers, checkout the SVG below). Since `r` is declared on line 4 to be a reference to `i32`, it comes into scope on line 4 and got dropped after where it's last used, which is the immediate line after `println!`. So `r` lives for [#4, #10].
Having all lifetimes calculated properly, let's draw out the lifetime visualization for `fn max<'a>` in the caller's point of view:

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="lifetime_func_max code_panel" data="assets/code_examples/lifetime_func_max/vis_code.svg"></object>
  <object type="image/svg+xml" class="lifetime_func_max tl_panel" data="assets/code_examples/lifetime_func_max/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('lifetime_func_max')"></object>
</div>


`'a` should be able to encompass the lifetime of all three references and be as small as possible, so as to reduce the amount of constraint bound to the programmer. In this case, `'a = [#4, #10]`, the same as the lifetime of `r`. Try hover on the SVG to see more!

## Type Lifetime Parameters

A `struct` must have explicit lifetime parameter annotations if it contains a reference. The reason is simple: the reference can't outlive the lender variable, so the `struct` also cannot. Lifetime parameters are the way to correlate the lifetime of the reference and `struct`.

Let's see how the lifetime parameter is computed when used to annotate a struct:

```rust
struct Book<'a>{
    name: &'a String,
    serial_num: i32
}

impl<'a> Book<'a>{
    fn new(_name: &'a String, _serial_num: i32) -> Book<'a>{
        Book { name: _name, serial_num: _serial_num }
    }
}
```

Here we define a `Book` struct that contains an immutable reference to a `String`. `'a` means that if the lifetime of `Book` is `'a`, then the lifetime of `name : &'a String` will be at least `'a`.

The `impl` block contains one function that create `Book` type in a factory mode. Let's look at an example of calling this function:

```rust
fn main(){
    let mut name = String::from("The Rust Book");
    let serial_num = 1140987;
    {
        let rust_book = Book::new(&name, serial_num);
        println!("The name of the book is {}",rust_book.name);
    }
    name = String::from("Behind Borrow Checker");
    println!("New name: {}",name);
}
```

First and foremost, let's calculate the lifetime of each variable (this will always be the first step, so bear in mind). It suffices to just look at line numbers and scoping curly brackets:

| Variable     | Lifetime |
|:------------:|:--------:|
| `name`       | [#7, #15] |
| `serial_num` | [#8, #15] |
| `rust_book`  | [#10, #12] |

Note that since `rust_book` is in an inner scope, it will be destructed when the scope ends. To calculate lifetime parameter on `Book::new()` invoked on line 10, we list all constraints to the lifetime parameter `'a`.

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="lifetime_rustbook code_panel" data="assets/code_examples/lifetime_rustbook/vis_code.svg"></object>
  <object type="image/svg+xml" class="lifetime_rustbook tl_panel" data="assets/code_examples/lifetime_rustbook/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('lifetime_rustbook')"></object>
</div>


Since `&name` is a temporary variable created just to be passed on line 10, its lifetime will be limited only to line 10.

Therefore, `'a` inside the `impl` block will cover lifetime of `rust_book` and `&name` (`serial_num` has nothing to do as it's not annotated by `'a`). So, `'a` = [#10, #12].


Note that this program runs well because every usage of a reference is within its legal lifetime scope. For example, changing `name` on line 13 won't cause a `value still borrowed` error since `rust_book.name`, which is a reference to `name`, has been out of scope after line 12.

##### About reference passed on the fly

You may question why `&name` is only live on line 10. We could imagine  the borrow checker will create a reference to `name` and pass that reference to the function, and everything is happening on a single line:

```rust
 let tmp = &name; let rust_book = Book::new(tmp, serial_num); // both happens on line 10
 // tmp's lifetime is end here
```

As [NLL lifetime](https://stackoverflow.com/questions/50251487/what-are-non-lexical-lifetimes) defines a reference's lifetime ends after its last usage, `tmp` is created on line 10 and also ended on the same line. We will treat lifetime of references created on the fly in this way in the following tutorial.

## Lifetime Parameter - A More Complex Example

Previous examples have equipped you with the basic methodology for reasoning out generic lifetime parameters, just as the borrow check does. In this section, we will use lifetime parameters to construct a real-life problem-solver: a scheduler program that processes requests in a database. Let's dive in.

### Modeling Requests Using Structs

First, we need to prototype incoming requests for our database. For simplicity, the DB system only supports four kinds of operations: `Create`, `Read`, `Update`, and `Delete`, or [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete). Each kind of request will be issued in batches by different users. To model that, we can define an `enum` of all CRUD request types:

```rust
enum RequestType{
    CREATE,
    READ,
    UPDATE,
    DELETE,
}

impl RequestType {
    fn to_string(&self) -> String{
        match self {
            RequestType::CREATE => String::from("create"),
            RequestType::READ => String::from("read"),
            RequestType::UPDATE => String::from("update"),
            RequestType::DELETE => String::from("delete"),
        }
    }
}
```

We can also add a simple `impl` function `to_string()` for easy logging. Then, our `Request` struct should contain:

+ `request_type: RequestType`, which is the type of CRUD request

+ `num_request_left: &mut u32`, the number of CRUD requests in a batch. A mutable reference to `u32` means if our database can't handle a full batch of request, we will process as many as we can and the mutable reference records how many requests are served.

```rust
struct Request<'a>{
    num_request_left: &'a mut u32,
    request_type: RequestType
}

impl<'a> Request<'a>{
    fn new(_num_request: &'a mut u32, _request_type: RequestType) -> Request<'a>{
        Request { num_request_left: _num_request, request_type: _request_type }
    }
}
```

Note that since `struct Request` contains a reference, we must make sure `Request` instance doesn't outlive the lender of `num_request_left`, meaning an explicit lifetime parameter is needed. For convenience, we also define a `Request::new()` function to create `Request` in factory mode. The rational behind the lifetime annotation has already been explained in the previous section.

#### Data Structure for Our Request Queue: `VecDeque`

`std::collections::VecDeque` is just like `std::deque<T>` in C++, which can either be FIFO or FILO order. We will choose FIFO to process the incoming requests. Let's first get familiar with this data structure with two examples:

+ Correct usage:

```rust
use std::collections::VecDeque;

1 fn main(){
2    let mut queue:VecDeque<&i32> = VecDeque::new();
3    let a = 10;
4    let b = 9;
5    queue.push_back(&a);
6    queue.push_back(&b);
7    loop {
8        if let Some(num) = queue.pop_front(){
9           println!("element: {}",num);
10        }
11        else {
12           break;
13        }
14    }
15 }
```

Here, we create a `VecDeque` to store `&i32`, because later we're going to store a reference to `Request`, so it's beneficial to find some insights on using references as stored data beforehand. On lines 5-6, we push references of `a` and `b` into the queue. Then, we loop through the queue in FIFO order by calling `pop_front()`. Note that unlike C++, the return type of `pop_front()` is not `&i32` but `Option<&i32>`:

> `alloc::collections::vec_deque::VecDeque`
> 
> `pub fn pop_front(&mut self) -> Option<T>`
> 
> ---
> 
> Removes the first element and returns it, or `None` if the deque is empty.

This provides a safety net if the user calls `pop_front()` when `VecDeque` is empty. To inspect whether `queue` is empty or not, we use `if let` syntax to extract the value stored in the front of queue,  and break if we see a `Option::None`.

+ Erroneous Usage:

```rust
1 fn main(){
2    let mut queue:VecDeque<&i32> = VecDeque::new();
3    {
4        let a = 10;
5        let b = 9;
6        queue.push_back(&a);
7        queue.push_back(&b);
8    }
9    let c = 6;
10   queue.push_back(&c);
11    // error: `a` does not live long enough
12    // label: borrow later used here
13    // error: `b` does not live long enough
14    // label: borrow later used here
15 }
```

The borrow checker will complain at line 10 that `a` and `b` don't live long enough. This is obvious, since `a` and `b` are in the inner scope which ends at line 8. However, references to `a` and `b` are still inside `queue` till line 10. This will cause an invalid read to deallocated stack space, which the borrow check will prevent during compile time.

Therefore, an important insight into a `Vecdeque` holding references is that *the lifetime of `VecDeque` is bounded by the shortest lifetime among all references it stores*. This can be explained by the  [lifetime elision rule](https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html#lifetime-elision) on method definition.

![](/Users/alaric66/Desktop/research/RustViz/Rust-blog/2023-06-04-12-46-13-image.png)

Since `a` and `b` only live from lines 4,5 to line 8, the lifetime of `queue` lasts at most until line 8. So if we remove the stuff after line 9, the borrow check will let us pass.

### Process DB Requests

We're so close to our goal! Let's design how our database handles user requests. It's typical that there will be multiple threads inside a database that serve requests concurrently, and each thread grabs some resources from a pool. We simplify each thread into a function that takes a queue of `Request`, and the number of resources it possesses, `max_process_unit`, meaning the maximum number of CRUD operations it can perform:

```rust
/// process requests passed from a mutable deque, return the front request if it hasn't been fully served
///
/// # Arguments
///
/// * 'queue' - A mutable reference to deque which stores requests in FIFO order, requests are mutable reference to Request struct type
///
/// * 'max_process_unit' - A mutable reference to maximal number of operation (READ, UPDATE, DELETE) it can serve
///
fn process_requests<'i,'a>(queue: &'i mut VecDeque<&'i mut Request<'i>>, max_process_unit: &'a mut u32) -> Option<&'i mut Request<'i>>{
    loop {
        let front_request: Option<&mut Request> = queue.pop_front();
        if let Some(request) = front_request{
            // if current max_process_unit is greater than current requests
            if request.num_request_left <= max_process_unit{
                println!("Served #{} of {} requests.", request.num_request_left, request.request_type.to_string());
                // decrement the amount of resource spent on this request
                *max_process_unit = *max_process_unit - *request.num_request_left;
                // signify this request has been processed
                *request.num_request_left = 0;
            }
            // not enough
            else{
                // process as much as we can
                *request.num_request_left = *request.num_request_left - *max_process_unit;
                // sad, no free resource anymore
                *max_process_unit = 0;
                // enqueue the front request back to queue, hoping someone will handle it...
                // queue.push_front(request);
                return Option::Some(request);
            }
            //
        }
        else {
            // no available request to process, ooh-yeah!
            return Option::None;

        }
    }
}
```

We won't hasten to explain how lifetime parameter works here; instead, we will embed it in some caller. For now, just understand what it wants to accomplish:

1. First, loop through a batch of requests in FIFO order;

2. When `queue` is not empty, serve the front request as much as we can.
   
   + If `max_process_unit` is enough to cover this request, just decrements `max_process_unit` by `request.num_request_left` and keeps processing;
   
   + If `max_process_unit` is not enough to complete the whole request, we will return the request reference and hope some other handler will process it, or just put it back to the queue, which is out of our concern.

3. If `queue` is empty, it means all requests have been served and we return blissfully. 

### Finally Inside the Database

Eventually, we're able to put together all the pieces and design our DB. For simplicity, we will model this as single-threaded:

```rust
1 fn main() {
2    // requests, resources generated by main thread
3    let mut available_resource: u32 = 60;
4    let mut request_queue: VecDeque<&mut Request> = VecDeque::new();
5    let reads_cnt: u32 = 20;
6    let mut RD_rq: Request = Request::new(reads_cnt, RequestType::READ);
7    request_queue.push_back(&mut RD_rq);
8    let updates_cnt: u32 = 30;
9    let mut UD_rq: Request = Request::new(updates_cnt, RequestType::UPDATE);
10    request_queue.push_back(&mut UD_rq);
11    let deletes_cnt: u32 =50;
12    let mut DL_rq: Request = Request::new(deletes_cnt, RequestType::DELETE);
13    request_queue.push_back(&mut DL_rq);
14    // ..., process requests in multi-threading way ...
15    // this might be another thread that deal with request processing ...
16    let ptr_to_resource = &mut available_resource;
17    let request_halfway = process_requests(&mut request_queue, ptr_to_resource);
18    if let Some(req) = request_halfway {
19        println!("#{} of {} requests are left unprocessed!", req.num_request_left, req.request_type.to_string());
20    }
21    println!("there are #{} free resource left.", available_resource);
22 }
```

Let's first calculate the lifetime of each *variable*, since `Request` contains lifetime parameter itself. By previous section, it's easy to verify lifetime via function signature of `Request::new()` function. Therefore, we obtain the following table of variable lifetime:


| variable                                    | lifetime (scope) |
|:-------------------------------------------:|:----------------:|
| `mut request_queue: VecDeque<&mut Request>` | [#4, #22]        |
| `mut reads_cnt : u32`                       | [#5, #22]        |
| `mut RD_rq: Request`                        | [#4, #22]        |
| `mut updates_cnt : u32`                     | [#8, #22]        |
| `mut UD_rq: Request`                        | [#9, #22]        |
| `mut deletes_cnt : u32`                     | [#11, #22]       |
| `mut DL_rq: Request`                        | [#12, #22]       |
| `mut available_resource: u32`               | [#3, #22]        |
| `request_halfway : Option<mut Request>`     | [#17, #18]       |
| `ptr_to_resource: &mut u32`                 | [#16, #18]       |

You may ask why lifetime of `request_halfway` only lasts to line 18 rather than the end of `main`. That's because on line 18, the `if let` expression may have moved resource from `request_halfway` to the new variable created in `if let` inner scope `req`. Even though we're not guaranteed to enter this conditional branch, the borrow checker has to be prudential so as to avoid any possible invalid pointer access. Therefore lifetime of `request_halfway` has to end earlier.
Moreover, noticed that the first argument passed to `process_requests()` is of type `&'i mut VecDeque<&'i mut Request<'i>>`. This means not only the lifetime of reference to `VecDeque`, but also lifetimes of objects contained by `VecDeque` should be considered into calculation of `'i`. Hence, we need to calculate lifetimes of references added to `request_queue` as well, which is easy to just look at when the references got pushed into the queue:

| variable                                    | lifetime (scope) |
|:-------------------------------------------:|:----------------:|
| `&mut RD_rq`                                | [#6, #22]        |
| `&mut UD_rq`                                | [#9, #22]        |
| `&mut DL_rq`                                | [#12, #22]       |

Note that all 3 references get dropped on line 22, which is the end of `main`. It's because they're still in the `request_queue` and never get destroyed. Even though it's possible one of them get popped out from the queue inside `process_request()` so we can mark the lifetime of that reference ends on line 17, the borrow checker cannot do that during compile time because it totally depends on input in runtime. Hence, we have to adopt the conservative resort.

Having all constraints ready, we can layout our calculation for `'a` and `'i` (hover on SVG to find more detailed explanations!):

<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">
  <object type="image/svg+xml" class="lifetime_db code_panel" data="assets/code_examples/lifetime_db/vis_code.svg"></object>
  <object type="image/svg+xml" class="lifetime_db tl_panel" data="assets/code_examples/lifetime_db/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('lifetime_db')"></object>
</div>


## Conclusion
In this tutorial, we showed you how to understand how lifetime parameter works and how to properly calculate the scope of each lifetime parameter, for the purpose of grasping the rationale behind the Rust borrow checker. Through Rustviz visualization tool, we can illustrate how borrow checker generates constraints for lifetime parameter in a more vivid way. If you found this kind of visualization useful, welcome to download Rustviz and create your own visualization on Rust lifetime parameter!