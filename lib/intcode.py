#!/usr/bin/env python3
import argparse


class IntCodeComputer(object):
    def __init__(self, intcode, input_=None):
        self.instructions = {
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
        self.intcode = intcode  # intcode list
        self.p = 0  # instruction pointer: address
        self.parameter_mode = 0  # (0): positional || 1: immediate
        self.relative_base = 0
        self.input = input_ if input_ else []
        self.wait_for_input = True
        self.output = []

    @staticmethod
    def load_intcode(intcode_file):
        with open(intcode_file, "r") as f:
            data = f.read().replace('\n', '').replace(',', ' ')
            return [int(op_code) for op_code in data.split(' ')]

    def start_program(self):
        return self.step_program()

    def step_program(self, input_=None):
        self.input.extend(input_ if input_ else [])
        self.wait_for_input = False
        self.output = []

        while True:
            code = self.intcode[self.p]
            op_code = code % 100
            if op_code == 99:
                break
            elif op_code in self.instructions:
                self.parameter_mode = code // 100
                self.parse_instruction(self.instructions[op_code])
                if self.wait_for_input:
                    break
            else:
                raise ValueError("Error: op_code unknown: %s" % op_code)
        return self.output.copy()

    def parse_instruction(self, instruction_name):
        instruction = getattr(self, instruction_name)
        if not instruction:
            raise NotImplementedError("Error: Instruction %s not implemented" % instruction_name)
        return instruction()

    def instruction_pointer_address(self, index):
        parameter_mode = (self.parameter_mode // (10 ** (index - 1))) % 10
        if parameter_mode == 0:
            ip_address = self.intcode[self.p + index]
        if parameter_mode == 1:
            ip_address = self.p + index
        if parameter_mode == 2:
            ip_address = self.relative_base + self.intcode[self.p + index]

        try:
            return ip_address
        except NameError as e:
            print(e)

    def allocate_address(self, ip_address):
        [self.intcode.extend([0]) for i in range(len(self.intcode), ip_address + 1)]

    def _get(self, index):
        ip_address = self.instruction_pointer_address(index)
        try:
            return self.intcode[ip_address]
        except IndexError:
            return 0

    def _set(self, index, value):
        ip_address = self.instruction_pointer_address(index)
        if ip_address >= len(self.intcode):
            self.allocate_address(ip_address)
        self.intcode[ip_address] = value

    def _add(self):
        self._set(3, self._get(1) + self._get(2))
        self.p += 4

    def _multiply(self):
        self._set(3, self._get(1) * self._get(2))
        self.p += 4

    def _input(self):
        if len(self.input):
            value = self.input.pop(0)
        else:
            self.wait_for_input = True
            return
        self._set(1, value)
        self.p += 2

    def _output(self):
        value = self._get(1)
        self.output.append(value)
        self.p += 2

    def _jump_if_true(self):
        if self._get(1) != 0:
            self.p = self._get(2)
        else:
            self.p += 3

    def _jump_if_false(self):
        if self._get(1) == 0:
            self.p = self._get(2)
        else:
            self.p += 3

    def _less_than(self):
        if self._get(1) < self._get(2):
            self._set(3, 1)
        else:
            self._set(3, 0)
        self.p += 4

    def _equals(self):
        if self._get(1) == self._get(2):
            self._set(3, 1)
        else:
            self._set(3, 0)
        self.p += 4

    def _adjust_base(self):
        self.relative_base += self._get(1)
        self.p += 2


def main():
    params = argparse.ArgumentParser()
    params.add_argument("--intcode")
    params.add_argument("--noun")
    params.add_argument("--verb")
    params.add_argument("--input")
    args = params.parse_args()
    input_ = []
    intcode = False

    if args.intcode:
        intcode = IntCodeComputer.load_intcode(args.intcode)

    if args.noun:
        intcode[1] = int(args.noun)
    if args.verb:
        intcode[2] = int(args.verb)

    if args.input:
        input_ = [int(x) for x in args.input.split(' ')]

    computer = IntCodeComputer(intcode, input_)
    while computer.wait_for_input:
        computer.start_program()
        if computer.wait_for_input:
            value = input("Enter input: ")
            computer.step_program([int(value)])


if __name__ == "__main__":
    main()
