// https://adventofcode.com/2019/day/16

//    rustc main.rs && ./main

use std::fs;
use std::error::Error;


fn fft(input: &str, phases: i32) -> Result<Vec<i32>, Box<dyn Error>>{
    let mut values = input
        .trim()
        .chars()
        .map(|c| c.to_digit(10).map(|d| d as i32).ok_or("Not Digit"))
        .collect::<Result<Vec<_>, _>>()?;

    let mut phase = values.clone();
    let pattern = [0, 1, 0, -1];
    for _ in 0..phases {
        for (i, out) in phase.iter_mut().enumerate() {
            let mut sum = 0;
            let mut counter = i + 1;
            let mut p_digit = 1;
            for digit in &values[i..] {
                if counter == 0 {
                    counter = i + 1;
                    p_digit = (p_digit + 1) % pattern.len();
                }
                sum += *digit * pattern[p_digit];
                counter -= 1;
            }
            *out = sum.abs() % 10;
        }
        values = phase.clone();
    }
    Ok(values)
}


fn part2(digits: &[i32]) -> i32 {
    let offset = digits[..7]
        .iter()
        .fold(0, |n, &d| 10 * n + d) as usize;
    let suffix_len = digits.len() * 10_000 - offset;
    let mut suffix: Vec<_> = digits
        .iter()
        .copied()
        .rev()
        .cycle()
        .take(suffix_len)
        .collect();
    for _ in 0..100 {
        let mut prev = suffix[0];
        for x in &mut suffix[1..] {
            *x += prev;
            *x %= 10;
            prev = *x;
        }
    }
    suffix.iter().rev().take(8).fold(0, |n, &d| 10 * n + d)
}


fn main() -> Result<(), Box<dyn Error>> {
    let input = fs::read_to_string("input.txt")?;
    let output_full = fft(&input, 100)?;
    let output_first8 = &output_full[..8];
    let output = output_first8
        .into_iter()
        .map(|i| i.to_string())
        .collect::<String>();
    println!("output: {}", output);

    let digits: Vec<_> = input
        .trim()
        .chars()
        .map(|c| c.to_digit(10).map(|d| d as i32).ok_or("Not Digit"))
        .collect::<Result<Vec<_>, _>>()?;
    let output_p2 = part2(&digits);
    println!("output p2: {}", output_p2);
    Ok(())
}
