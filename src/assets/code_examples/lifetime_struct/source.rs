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

impl<'a> Book<'a>{
    fn new(_name: &'a String, _serial_num: i32) -> Book<'a>{
        Book { name: _name, serial_num: _serial_num }
    }
}