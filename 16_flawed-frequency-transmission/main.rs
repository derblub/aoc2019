// https://adventofcode.com/2019/day/16

//    rustc main.rs && ./main

use std::fs;


fn main(){
    let input = fs::read_to_string("input.txt").expect("error reading input file");
    println!("input:\n{}", input);
}
