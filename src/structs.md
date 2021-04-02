### Structs in Rust

#### Creating a struct

To define a struct, we enter the keyword `struct` and name the entire struct. A struct’s name should describe the significance of the pieces of data being grouped together. Then, inside curly brackets, we define the names and types of the pieces of data, which we call *fields*. Here is an example showing a struct that stores information about a user account.

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```

We create an instance by stating the name of the struct and then add curly brackets containing `key: value` pairs, where the keys are the names of the fields and the values are the data we want to store in those fields.  Then we can use dot field to obtain the value in a struct.

```rust
    let mut user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    user1.email = String::from("anotheremail@example.com");
```

Here's an example of defining a struct, generate an instance of it and let it interact with functions.

```rust
struct Rect {
    w: u32,
    h: u32,
}

fn main() {
    let r = Rect {
        w: 30,
        h: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        area(&r)
    );
    
    println!(
    	"The height of that is {}.", r.h
    );
}

fn area(rect: &Rect) -> u32 {
    rect.w * rect.h
}
```

#### Calling a method in a struct

Struct can also include methods whose definition is given in the ```impl``` of it.  When calling a method or a variable from a struct, we use ```object.something()```or ``` (&object).something()```, which are the same. No matter it is a ```&, &mut, *```or nothing, always use ```.``` and not need to use ```->``` because Rust will automatically adds in ```&, &mut, *``` so ```object``` matches the signature of the method. 

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
}

fn printArea(rect: &Rect) -> u32 {
    println!(
        "The area of the rectangle is {} square pixels.",
       	rect.area() // dot even though it's actually a reference
    );
}

```



#### Ownership of struct data

When the instance of the struct owns all its data members, i.e. no reference or pointer in the struct, the ownership is basically the same with data outside of a struct. The only thing to mention is that the struct instance go out of scope after all its members go out of scope.

Here's an example of the cases where all data members are owned the the struct.

```rust
struct Foo {
    x: i32,
    y: String,
}

fn main() {
    let _y = String :: from("bar");
    let f = Foo { x: 5, y: _y };
    println!("{}", f.x);
    println!("{}", f.y);
}
```

When the any of the data members is not owned by the struct, it needs lexical lifetime specified. 

Here is an example of using lifetime annotations in struct definitions to allow reference in a struct.

```rust
struct Excerpt<'a> {
    p: &'a str,
}

fn main() {
    let n = String::from("Ok. I'm fine.");
    let first = n.split('.').next().expect("Could not find a '.'");
    let i = Excerpt {
        p: first,
    };
}
```

