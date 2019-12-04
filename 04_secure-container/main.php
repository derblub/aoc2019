<?php

# https://adventofcode.com/2019/day/4

$input = '193651-649729';
$input = preg_split('#(?<=\d)-(?=\d)#i', $input);


function is_increasing(int $code): bool {
  $str = (string) $code;
  for ($i=0; $i<strlen($str)-1; $i++){
    if ($str[$i] > $str[$i+1]){
      return false;
    }
  }
  return true;
}

function has_double_digits(int $code): bool {
  return preg_match('/11|22|33|44|55|66|77|88|99|00/', (string) $code) > 0;
}

function has_double_digits_not_larger(int $code): bool {
  $str = (string) $code;
  for ($i=0; $i<strlen($str)-1; $i++){
    $next_char_is_same = $str[$i] === $str[$i+1];
    $next_after_char_is_different = $i === strlen($str) - 2 || $str[$i] !== $str[$i+2];
    $prev_char_is_different = $i === 0 || $str[$i] !== $str[$i-1];
    if ($next_char_is_same && $next_after_char_is_different && $prev_char_is_different){
      return true;
    }
  }
  return false;
}

function is_valid_code(int $code, bool $tripple_digit_check): bool {
  if ($tripple_digit_check){
    return is_increasing($code) && has_double_digits_not_larger($code);
  }
  return  is_increasing($code) && has_double_digits($code);
}

function count_valid_codes(int $from, int $to, bool $tripple_digit_check): int {
  $valid_int_count = 0;
  for ($code=$from; $code <=$to; $code++){
    if (is_valid_code($code, $tripple_digit_check)){
      $valid_int_count++;
    }
  }
  return $valid_int_count;
}

echo sprintf("output: %d\n", count_valid_codes($input[0], $input[1], false));
echo sprintf("output p2: %d\n", count_valid_codes($input[0], $input[1], true));
