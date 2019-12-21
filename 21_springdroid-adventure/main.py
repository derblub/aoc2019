# https://adventofcode.com/2019/day/21


import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from lib.intcode import IntCodeComputer


def render(output):
    for char in output:
        try:
            print(str(chr(char)), end='')
        except ValueError:
            print(str(char), end='')
    print()


def part1(computer):
    # !A || ((!B || !C) && D)
    springscript = "NOT B J" + "\n" \
                   "NOT C T" + "\n" \
                   "OR T J" + "\n" \
                   "AND D J" + "\n" \
                   "NOT A T" + "\n" \
                   "OR T J" + "\n" \
                   + "WALK" + "\n"
    input_ = [ord(x) for x in springscript]
    render(computer.start_program(input_))


def part2(computer):
    # !AD && !BD && !CDH
    springscript = "NOT A T" + "\n" \
                   "AND D T" + "\n" \
                   "OR T J" + "\n" \
                   "NOT B T" + "\n" \
                   "AND D T" + "\n" \
                   "OR T J" + "\n" \
                   "NOT C T" + "\n" \
                   "AND D T" + "\n" \
                   "AND H T" + "\n" \
                   "OR T J" + "\n" \
                   + "RUN" + "\n"
    input_ = [ord(x) for x in springscript]
    render(computer.start_program(input_))


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    part1(computer)
    part2(computer)


if __name__ == "__main__":
    main()
