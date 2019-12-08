#!/usr/bin/env python3
import argparse

instructions = {
    1: 'add',
    2: 'multiply',
    3: 'input',
    4: 'output',
    5: 'jump_if_true',
    6: 'jump_if_false',
    7: 'less_than',
    8: 'equals',
}


def _get(mem, index):
    parameter_mode = (mem['parameter_mode'] // (10 ** (index - 1))) % 10
    if parameter_mode == 0:
        return mem['intcode'][mem['intcode'][mem['p'] + index]]
    return mem['intcode'][mem['p'] + index]


def _set(mem, index, value):
    mem['intcode'][mem['intcode'][mem['p'] + index]] = value


def add(mem):
    if mem['parameter_mode'] // 100 == 0:
        _set(mem, 3, _get(mem, 1) + _get(mem, 2))
    mem['p'] += 4
    return mem


def multiply(mem):
    if mem['parameter_mode'] // 100 == 0:
        _set(mem, 3, _get(mem, 1) * _get(mem, 2))
    mem['p'] += 4
    return mem


def input(mem):
    print("input")
    mem['p'] += 2
    return mem


def output(mem):
    mem['p'] += 2
    return mem


def jump_if_true(mem):
    return mem


def jump_if_false(mem):
    return mem


def less_than(mem):
    return mem


def equals(mem):
    return mem


def load_input(input_file):
    with open(input_file, "r") as f:
        data = f.read().replace('\n', '').replace(',', ' ')
        return [int(opcode) for opcode in data.split(' ')]


def parse_instruction(instruction_name, mem):
    possible = globals().copy()
    possible.update(locals())
    instruction = possible.get(instruction_name)
    if not instruction:
        raise NotImplementedError("Error: Instruction %s not implemented" % instruction_name)
    return instruction(mem)


def parse_intcode(input):
    mem = {  # memory
        'intcode': input,     # intcode list
        'p': 0,               # instruction pointer: address
        'parameter_mode': 0,  # (0): positional || 1: immediate
    }
    while mem['p'] < len(input):
        code = mem['intcode'][mem['p']]
        opcode = code % 100
        if opcode == 99:
            break
        elif opcode in instructions:
            mem['parameter_mode'] = code // 100
            mem = parse_instruction(instructions[opcode], mem)
        else:
            raise ValueError("Error: opcode unknown: %s" % opcode)

    return mem['intcode']


def main():
    params = argparse.ArgumentParser()
    params.add_argument("--input")
    params.add_argument("--noun")
    params.add_argument("--verb")
    args = params.parse_args()
    input = output = False

    if args.input:
        input = load_input(args.input)

    if args.noun:
        input[1] = int(args.noun)
    if args.verb:
        input[2] = int(args.verb)

    if input:
        try:
            output = parse_intcode(input)
            print(str(output[0]))
        except ValueError as e:
            print(e)

    return output


if __name__ == "__main__":
    main()
