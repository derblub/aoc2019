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
    9: '_adjust_base',
}


def instruction_pointer_address(mem, index):
    parameter_mode = (mem['parameter_mode'] // (10 ** (index - 1))) % 10
    if parameter_mode == 0:
        ip_address = mem['intcode'][mem['p'] + index]
    if parameter_mode == 1:
        ip_address = mem['p'] + index
    if parameter_mode == 2:
        ip_address = mem['relative_base'] + mem['intcode'][mem['p'] + index]
    try:
        return ip_address
    except NameError as e:
        print(e)


def _get(mem, index):
    ip_address = instruction_pointer_address(mem, index)
    return mem['intcode'][ip_address]


def _set(mem, index, value):
    ip_address = instruction_pointer_address(mem, index)
    mem['intcode'][ip_address] = value


def _add(mem):
    _set(mem, 3, _get(mem, 1) + _get(mem, 2))
    mem['p'] += 4
    return mem


def _multiply(mem):
    _set(mem, 3, _get(mem, 1) * _get(mem, 2))
    mem['p'] += 4
    return mem


def _input(mem):
    if len(mem['input']):
        value = mem['input'].pop(0)
    else:
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
    if _get(mem, 1) < _get(mem, 2):
        _set(mem, 3, 1)
    else:
        _set(mem, 3, 0)
    mem['p'] += 4
    return mem


def _equals(mem):
    if _get(mem, 1) == _get(mem, 2):
        _set(mem, 3, 1)
    else:
        _set(mem, 3, 0)
    mem['p'] += 4
    return mem


def _adjust_base(mem):
    mem['relative_base'] += _get(mem, 1)
    mem['p'] += 2
    return mem


def load_intcode(intcode_file):
    with open(intcode_file, "r") as f:
        data = f.read().replace('\n', '').replace(',', ' ')
        return [int(opcode) for opcode in data.split(' ')]


def parse_instruction(instruction_name, mem):
    possible = globals().copy()
    possible.update(locals())
    instruction = possible.get(instruction_name)
    if not instruction:
        raise NotImplementedError("Error: Instruction %s not implemented" % instruction_name)
    return instruction(mem)


def parse_intcode(intcode, input=False):
    mem = {  # memory
        'intcode': intcode,   # intcode list
        'p': 0,               # instruction pointer: address
        'parameter_mode': 0,  # (0): positional || 1: immediate
        'input': input,
        'output': [],
        'relative_base': 0,
    }
    while mem['p'] < len(intcode):
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
    params.add_argument("--intcode")
    params.add_argument("--noun")
    params.add_argument("--verb")
    params.add_argument("--input")
    args = params.parse_args()
    intcode = output = input = False

    if args.intcode:
        intcode = load_intcode(args.intcode)

    if args.noun:
        intcode[1] = int(args.noun)
    if args.verb:
        intcode[2] = int(args.verb)

    if args.input:
        input = [int(x) for x in args.input.split(' ')]

    if intcode:
        try:
            output = parse_intcode(intcode, input)
            print(str(output))
        except ValueError as e:
            print(e)

    return output


if __name__ == "__main__":
    main()
