#!/usr/bin/env bash

# https://adventofcode.com/2019/day/2

execute_opcode() {
  INPUT='./input.txt'
  INTCODE=($(sed 's/,/ /g' ${INPUT}))
  INTCODE[1]=$1
  INTCODE[2]=$2
  POS=0
  while [[ true ]]; do
    opcode=${INTCODE[$POS]}
    if [[ $opcode -eq 99 ]]; then
      break
    else
      in1=${INTCODE[$POS+1]}
      in2=${INTCODE[$POS+2]}
      out=${INTCODE[$POS+3]}
      if [[ $opcode -eq 1 ]]; then
        INTCODE[out]=$((${INTCODE[$in1]} + ${INTCODE[$in2]}))
      elif [[ $opcode -eq 2 ]]; then
        INTCODE[out]=$((${INTCODE[$in1]} * ${INTCODE[$in2]}))
      else
        echo "ERROR"; exit 1
      fi
    fi
    (( POS += 4 ))
  done
  echo "${INTCODE[0]}"
}

# p1
echo "output: $(execute_opcode 12 2)"

# p2
echo "output p2: <bruteforcing, please wait>"
for noun in `seq 0 99`; do
  for verb in `seq 0 99`; do
    value=$(execute_opcode $noun $verb)
    if [[ $value -eq 19690720 ]]; then
      tput cuu1; tput el  # move cursor up one line and clear line
      result=$(((100 * $noun) + $verb))
      echo "output p2: ${result}"; exit 0
    fi
  done
done
