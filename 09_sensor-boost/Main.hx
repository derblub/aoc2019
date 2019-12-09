// https://adventofcode.com/2019/day/9

//   haxe -main Main --interp

import sys.io.Process;


class Main {
  static public function main():Void {
    var machine = new Process("python", ["../lib/intcode.py", "--intcode", "input.txt" ]);
    trace("exitcode: " + machine.exitCode());
    trace("process id: " + machine.getPid());

    // read everything from stderr
    var error = machine.stderr.readAll().toString();
    trace("stderr:\n" + error);

    // read everything from stdout
    var stdout = machine.stdout.readAll().toString();
    trace("stdout:\n" + stdout);

    machine.close();
  }
}
