#[no_mangle]
pub fn model_add(left: i32, right: i32) -> i32 {
    let (result, _overflow) = left.overflowing_add(right);
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = model_add(2, 2);
        assert_eq!(result, 4);
    }
}
