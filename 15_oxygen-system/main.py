# https://adventofcode.com/2019/day/15


import os
import sys
import time
import collections

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from lib.intcode import IntCodeComputer

WALL = 0
MOVE = 1
O2 = 2
#    N(1)        S(2)       E(3)        W(4)
D = {1: (0, -1), 2: (0, 1), 3: (-1, 0), 4: (1, 0)}


def path_back(x, y, prev_path):
    path = []
    while (x, y) in prev_path:
        x, y, direction = prev_path[x, y]
        path.append((x, y, direction))
    return path[::-1]


def explore_area(x, y, maze):
    queue = collections.deque([(x, y)])
    explored = {(x, y)}
    path = {}
    while queue:
        path_x, path_y = queue.popleft()
        if (path_x, path_y) not in maze:
            return path_back(path_x, path_y, path)
        for d, (dir_x, dir_y) in D.items():
            dir_x += path_x
            dir_y += path_y
            if (dir_x, dir_y) in explored:
                continue
            if maze.get((dir_x, dir_y)) == WALL:
                continue
            explored.add((dir_x, dir_y))
            path[dir_x, dir_y] = (path_x, path_y, d)
            queue.append((dir_x, dir_y))
    return False


def steps_to_o2(maze):
    queue = collections.deque([(0, 0, 0)])
    explored = {(0, 0)}
    while queue:
        path_x, path_y, distance = queue.popleft()
        if maze[path_x, path_y] == O2:
            return distance
        for dir_x, dir_y in D.values():
            dir_x += path_x
            dir_y += path_y
            if (dir_x, dir_y) in explored:
                continue
            if maze[dir_x, dir_y] == WALL:
                continue
            explored.add((dir_x, dir_y))
            queue.append((dir_x, dir_y, distance + 1))
        # @TODO draw path


def distance_to(pos, maze):
    queue = collections.deque([(*pos, 0)])
    explored = {pos}
    while queue:
        path_x, path_y, distance = queue.popleft()
        for dir_x, dir_y in D.values():
            dir_x += path_x
            dir_y += path_y
            if (dir_x, dir_y) in explored:
                continue
            if maze[dir_x, dir_y] == WALL:
                continue
            explored.add((dir_x, dir_y))
            queue.append((dir_x, dir_y, distance + 1))
        # @TODO draw path
    return distance


def draw_maze(px, py, maze, path=[]):
    af = '\x1b[38;5;{}m'.format
    ab = '\x1b[48;5;{}m'.format
    clear = '\x1b[0m'
    char_map = {None: " ", WALL: "░", MOVE: "∙", O2: "█"}
    path = set((x, y) for x, y, _ in path)

    output = []
    for y in range(-21, 20):
        for x in range(-21, 20):
            color = ""
            if (x, y) in path:
                color = ab(10)
            if (x, y) == (px, py):
                color += af(50)
                char = "@"
            else:
                char = char_map[maze.get((x, y))]
                if char == "·":
                    color += af(16)
            if color:
                char = f"{color}{char}{clear}"
            output.append(char)
        output.append("\n")
    print("".join(output))
    time.sleep(0.02)


def explore_maze(computer):
    maze = {(0, 0): MOVE}
    x, y = 0, 0
    output = computer.start_program()
    draw_maze(x, y, maze)
    while computer.wait_for_input:
        path = explore_area(x, y, maze)
        if not path:
            return maze
        for _, _, d in path:
            output = computer.step_program([int(d)])
            dir_x, dir_y = D[d]
            next_x, next_y = x + dir_x, y + dir_y
            # res = next(output)
            res = output[0]
            maze[next_x, next_y] = res
            if res:
                x, y = next_x, next_y
            draw_maze(x, y, maze, path)


def main():
    program = IntCodeComputer.load_intcode('input.txt')
    computer = IntCodeComputer(program)
    maze = explore_maze(computer)
    output1 = steps_to_o2(maze)
    print("output: %d" % int(output1))

    air = next(pos for pos, kind in maze.items() if kind == O2)
    output2 = distance_to(air, maze)
    print("output p2: %d" % int(output2))


if __name__ == "__main__":
    main()
