extern "C" {
    pub fn test(arr: *mut u8, len: u32) -> *mut u8;
}
fn main() {
    let mut arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    let len = (arr.len() * 4) as u32;
    let ptr = unsafe { test(arr.as_mut_ptr(), len) };
    let arr = unsafe { std::slice::from_raw_parts(ptr, arr.len()) };
    println!("{:?}", arr);
}
