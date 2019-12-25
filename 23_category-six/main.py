# https://adventofcode.com/2019/day/23


import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from lib.intcode import IntCodeComputer


def part1(computer):
    pass


def part2(computer):
    pass


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    part1(computer)
    part2(computer)


if __name__ == "__main__":
    main()
