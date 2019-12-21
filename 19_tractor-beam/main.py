# https://adventofcode.com/2019/day/19


import os
import sys
import itertools

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from lib.intcode import IntCodeComputer


scan = {
    0: '░',
    1: '▓',
    2: 'O'
}


def check_point(computer, x, y):
    input_ = [x, y]
    output = computer.start_program(input_)
    if output == [1]:
        return True
    return False


def scan_area(computer, affected_points=[]):
    for y in range(50):
        for x in range(50):
            value = check_point(computer, x, y)
            if value:
                affected_points.append((x, y))
            print(scan[value], end='')
        print()
    return affected_points


def find_y(computer, x, y):
    min_y = max_y = None
    for next_y in itertools.count(y, 1):
        value = check_point(computer, x, next_y)
        if value == 0:
            if min_y is not None:
                break
        elif value == 1:
            if min_y is None:
                min_y = next_y
            max_y = next_y
    return min_y, max_y


def find_square(computer, x, y):
    s = 100 - 1  # square length
    return check_point(computer, x, y) == 1 and check_point(computer, x + s, y) == 1 and \
        check_point(computer, x, y + s) == 1 and check_point(computer, x + s, y + s) == 1


def part2(computer):
    min_y = 1200  # make things faster
    for x in itertools.count(950, 1):  # make things faster
        min_y, max_y = find_y(computer, x, min_y)
        y = max_y + 1
        if y - min_y < 100:
            continue

        for y_ in itertools.count(min_y, 1):
            if y_ + 100 > y:
                break
            if find_square(computer, x, y_):
                return x * 10000 + y_  # calculation as per requirement


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    print("output: %d" % len(scan_area(computer)))
    print("output p2: %d" % part2(computer))


if __name__ == "__main__":
    main()
