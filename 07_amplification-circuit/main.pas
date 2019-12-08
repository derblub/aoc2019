
// https://adventofcode.com/2019/day/7

// fpc main.pas

program Main;

uses
  Process;

resourcestring
  error_runcommand = 'Error: runcommand failed.';
  output_empty = 'no output';

var
  input : AnsiString;
  output : AnsiString;

begin
  input := 'input.txt';

  writeln('loading IntCode program "', input, '"');

  if RunCommand('/usr/bin/bash', ['../02_1202-program-alarm/intcode.sh', input], output, [poStderrToOutPut]) then
    writeln(output)
  else
    writeln(error_runcommand);
    writeln(output)

end.
