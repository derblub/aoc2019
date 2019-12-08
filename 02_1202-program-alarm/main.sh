#!/usr/bin/env bash

# https://adventofcode.com/2019/day/2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INPUT="${DIR}/input.txt"

output="$(python "${DIR}"/../lib/intcode.py --input "${INPUT}" --noun 12 --verb 2)"

echo "output: ${output}"

# p2
echo "output p2: <bruteforcing, please wait>"
for noun in $(seq 0 99); do
  for verb in $(seq 0 99); do
    value="$(python "${DIR}"/../lib/intcode.py --input "${INPUT}" --noun "${noun}" --verb "${verb}")"
    if [[ $value -eq 19690720 ]]; then
      tput cuu1; tput el  # move cursor up one line and clear line
      result=$(((100 * $noun) + $verb))
      echo "output p2: ${result}"; exit 0
    fi
  done
done
