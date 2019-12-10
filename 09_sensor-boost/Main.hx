// https://adventofcode.com/2019/day/9

//   haxe -main Main --interp

import sys.io.Process;


class Main {
  static public function main():Void {
    var regexp:EReg = ~/output': \[(\d+)\]/;

    // p1
    var machine = new Process("python", ["../lib/intcode.py", "--intcode", "input.txt", "--input", "1" ]);
    var stdout = machine.stdout.readAll().toString();
    regexp.match(stdout);
    var output = regexp.matched(1);
    trace(output);
    machine.close();

    var machine = new Process("python", ["../lib/intcode.py", "--intcode", "input.txt", "--input", "2" ]);
    var stdout = machine.stdout.readAll().toString();
    regexp.match(stdout);
    var output = regexp.matched(1);
    trace(output);
    machine.close();

  }
}
