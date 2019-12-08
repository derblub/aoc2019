#!/usr/bin/env python3
import argparse

instructions = {
    1: '_add',
    2: '_multiply',
    3: '_input',
    4: '_output',
    5: '_jump_if_true',
    6: '_jump_if_false',
    7: '_less_than',
    8: '_equals',
}


def _get(mem, index):
    parameter_mode = (mem['parameter_mode'] // (10 ** (index - 1))) % 10
    if parameter_mode == 0:
        return mem['intcode'][mem['intcode'][mem['p'] + index]]
    return mem['intcode'][mem['p'] + index]


def _set(mem, index, value):
    mem['intcode'][mem['intcode'][mem['p'] + index]] = value


def _add(mem):
    if mem['parameter_mode'] // 100 == 0:
        _set(mem, 3, _get(mem, 1) + _get(mem, 2))
    mem['p'] += 4
    return mem


def _multiply(mem):
    if mem['parameter_mode'] // 100 == 0:
        _set(mem, 3, _get(mem, 1) * _get(mem, 2))
    mem['p'] += 4
    return mem


def _input(mem):
    if mem['parameter_mode'] % 10 == 0:
        value = int(input("Enter input: "))
        _set(mem, 1, value)
    mem['p'] += 2
    return mem


def _output(mem):
    value = _get(mem, 1)
    mem['output'].append(value)
    mem['p'] += 2
    return mem


def _jump_if_true(mem):
    if _get(mem, 1) != 0:
        mem['p'] = _get(mem, 2)
    else:
        mem['p'] += 3
    return mem


def _jump_if_false(mem):
    if _get(mem, 1) == 0:
        mem['p'] = _get(mem, 2)
    else:
        mem['p'] += 3
    return mem


def _less_than(mem):
    if mem['parameter_mode'] // 100 == 0:
        if _get(mem, 1) < _get(mem, 2):
            _set(mem, 3, 1)
        else:
            _set(mem, 3, 0)

    mem['p'] += 4
    return mem


def _equals(mem):
    if mem['parameter_mode'] // 100 == 0:
        if _get(mem, 1) == _get(mem, 2):
            _set(mem, 3, 1)
        else:
            _set(mem, 3, 0)

    mem['p'] += 4
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
        'output': [],
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

    return mem


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
            print(str(output))
        except ValueError as e:
            print(e)

    return output


if __name__ == "__main__":
    main()
