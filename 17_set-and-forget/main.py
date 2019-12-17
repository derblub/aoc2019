# https://adventofcode.com/2019/day/17


import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from lib.intcode import IntCodeComputer


PATH = '#'
SPACE = '.'
NL = '\n'
ROBOT = 'X^v<>'
TILES = {
    35: PATH,
    46: SPACE,
    10: NL,
    94: ROBOT[:1],
}


def calibrate_cam(map_):
    ap_sum = 0
    for x, row in enumerate(map_[1:-1]):
        for y, tile in enumerate(row[1:-1]):
            if (
                tile == PATH
                and map_[x][y + 1] == PATH
                and map_[x + 1][y] == PATH
                and map_[x + 1][y + 2] == PATH
                and map_[x + 2][y + 1] == PATH
            ):
                ap_sum += (x + 1) * (y + 1)
    return ap_sum


def render_grid(grid):
    tiles = []
    for tile in grid:
        tiles.append(TILES[tile])
    output = "".join(tiles)
    print(output)
    return [[c for c in line] for line in output.splitlines()]


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    out = computer.start_program()
    map_ = render_grid(out)
    print("output: %d" % calibrate_cam(map_))

    # while computer.wait_for_input:
    #     out = computer.step_program()
    #     if computer.wait_for_input:
    #         value = input("Enter input: ")
    #         out = computer.step_program([int(value)])
    # return out


if __name__ == "__main__":
    main()
