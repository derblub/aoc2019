#!/usr/bin/env python3

import os
import sys

with open(os.path.join(sys.path[0], "input.txt"), "r") as f:
    fuel_sum = 0
    fuel_sum_p2 = 0

    for mass in f:
        fuel = int(mass) // 3 - 2
        fuel_sum += fuel

        # p2
        while fuel > 0:
            fuel_sum_p2 += fuel
            fuel = fuel // 3 -2

    print("output: %d" % fuel_sum)
    print("output p2: %d" % fuel_sum_p2)
