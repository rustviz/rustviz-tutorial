struct Circle<'i>{
    r: &'i i32,
}
fn main(){
    let r1 = 10;
    let r2 = 9;
    let c = Circle{r: &r1 };
    let (opt,ptr) = c.cmp(&r2, &r1);
    println!("{} is larger", opt);
}
impl<'i,'a> Circle<'i,'a>{
    fn cmp(&'i self, other: &'i i32, op: &'a i32) -> (&'i i32, &'a i32){
        if self.r > other {self.r}
        else{other}
    }
}