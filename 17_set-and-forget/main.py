# https://adventofcode.com/2019/day/17


import re
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
    x, y = 0, 0
    grid = ["".join(line) for line in map_]
    turn_r = {
        (0, 1): (1, 0),
        (1, 0): (0, -1),
        (0, -1): (-1, 0),
        (-1, 0): (0, 1),
    }
    turn_l = {
        (0, 1): (-1, 0),
        (-1, 0): (0, -1),
        (0, -1): (1, 0),
        (1, 0): (0, 1),
    }
    direction = 0, +1
    path = ['R', 0]
    while True:
        nx, ny = x + direction[0], y + direction[1]
        if 0 <= nx <= len(grid) - 1 and 0 <= ny <= len(grid[0]) - 1 and grid[nx][ny] == '#':
            x, y = nx, ny
            path[-1] += 1
        else:
            r = turn_r[direction]
            nx, ny = x + r[0], y + r[1]
            if 0 <= nx <= len(grid) - 1 and 0 <= ny <= len(grid[0]) - 1 and grid[nx][ny] == '#':
                x, y = nx, ny
                direction = r
                path.append('R')
                path.append(1)
            else:
                l = turn_l[direction]
                nx, ny = x + l[0], y + l[1]
                if 0 <= nx <= len(grid) - 1 and 0 <= ny <= len(grid[0]) - 1 and grid[nx][ny] == '#':
                    x, y = nx, ny
                    direction = l
                    path.append('L')
                    path.append(1)
                else:
                    break
    return ','.join(str(s) for s in path)


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    out = computer.start_program()
    map_ = render_grid(out)
    output_p1 = calibrate_cam(map_)
    path = find_path(map_)

    # manual path mapping + zipping
    # L,12,L,8,R,10,R,10,L,6,L,4,L,12,L,12,L,8,R,10,R,10,L,6,L,4,L,12,R,10,L,8,L,4,R,10,L,6,L,4,L,12,L,12,L,8,R,10,R,10,R,10,L,8,L,4,R,10,L,6,L,4,L,12,R,10,L,8,L,4,R,10

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
