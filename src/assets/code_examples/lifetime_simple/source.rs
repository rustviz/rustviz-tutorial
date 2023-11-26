fn add_one<'i>(x: &'i mut u32){
    x += 1
}

fn main(){
    let val : i32 = 1;
    let x : &mut i32 = &mut val;
    add_one(x);
}