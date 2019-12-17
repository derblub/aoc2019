# https://adventofcode.com/2019/day/17


import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from lib.intcode import IntCodeComputer


def calibrate_cam(map_):
    ap_sum = 0
    for x, row in enumerate(map_[1:-1]):
        for y, tile in enumerate(row[1:-1]):
            if (
                tile == '#'
                and map_[x][y + 1] == '#'
                and map_[x + 1][y] == '#'
                and map_[x + 1][y + 2] == '#'
                and map_[x + 2][y + 1] == '#'
            ):
                ap_sum += (x + 1) * (y + 1)
    return ap_sum


def render_grid(grid, show=False):
    tiles = []
    for tile in grid:
        tiles.append(str(chr(tile)))
    output = "".join(tiles)
    if show:
        print(output)
    return [[c for c in line] for line in output.splitlines()]


def find_path(map_):
    pass


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    out = computer.start_program()
    map_ = render_grid(out)
    output_p1 = calibrate_cam(map_)

    # manual path mapping + zipping
    # L, 12, L, 8, R, 10, R, 10,        A
    # L, 6, L, 4, L, 12,                B
    # L, 12, L, 8, R, 10, R, 10,        A
    # L, 6, L, 4, L, 12,                B
    # R, 10, L, 8, L, 4, R, 10,         C
    # L, 6, L, 4, L, 12,                B
    # L, 12, L, 8, R, 10, R, 10,        A
    # R, 10, L, 8, L, 4, R, 10,         C
    # L, 6, L, 4, L, 12,                B
    # R, 10, L, 8, L, 4, R, 10,         C

    a = "L,12,L,8,R,10,R,10"
    b = "L,6,L,4,L,12"
    c = "R,10,L,8,L,4,R,10"
    zipped = "A,B,A,B,C,B,A,C,B,C"
    routine = zipped + "\n" + a + "\n" + b + "\n" + c + "\n" + "n\n"
    input_ = [ord(x) for x in routine]

    program[0] = 2
    computer = IntCodeComputer(program, input_)
    out = computer.start_program()
    map_ = render_grid(out, True)

    print("output: %d" % output_p1)
    print("output p2: %d" % out.pop())


if __name__ == "__main__":
    main()
