
// https://adventofcode.com/2019/day/7

// fpc main.pas

program Main;

uses
  Process,
  SysUtils;

resourcestring
  error_runcommand = 'Error: runcommand failed.';
  output_empty = 'no output';

var
  intcode_file : AnsiString;
  output : AnsiString;
  dir: String;
  I, J : Integer;
  ThrustersSignals : specialize TArray<Integer>;
  MaxSignal : Integer;
  PermutationList : TList<Integer>;
  input: String;

begin
  dir := GetCurrentDir;
  intcode_file := dir+'/input.txt';

  InputOutputArray : TArray<Integer>;
  setLength(ThrustersSignals,5);
  MaxSignal := 0;

  ThrustersSignals[0] := 1;
  ThrustersSignals[1] := 0;
  ThrustersSignals[2] := 4;
  ThrustersSignals[3] := 3;
  ThrustersSignals[4] := 2;

  PermutationList := TList<Integer>.Create;

  writeln('loading IntCode program "', input, '"');

  if RunCommand('python', ['../lib/intcode.py', '--intcode', intcode_file],
        output, [poStderrToOutPut]) then
    //writeln(output)
    for a := 0 to 4 do
      for b := 0 to 4 do
        for c := 0 to 4 do
          for d := 0 to 4 do
          begin
            PermutationList.Clear;
            PermutationList.AddRange([0,1,2,3,4]);
            ThrustersSignals[0] := PermutationList.Items[A];
            PermutationList.Remove(PermutationList.Items[A]);
            ThrustersSignals[1] := PermutationList.Items[B];
            PermutationList.Remove(PermutationList.Items[B]);
            ThrustersSignals[2] := PermutationList.Items[C];
            PermutationList.Remove(PermutationList.Items[C]);
            ThrustersSignals[3] := PermutationList.Items[D];
            PermutationList.Remove(PermutationList.Items[D]);
            ThrustersSignals[4] := PermutationList.Items[E];
            PermutationList.Remove(PermutationList.Items[E]);

            setLength(InputOutputArray,10);
            for I := 1 to Length(InputOutputArray) - 1 do
            begin
              InputOutputArray[I] := 0;
            end;

            for J := 0 to 4 do
            begin
              InputOutputArray[0] := ThrustersSignals[J];
              if RunCommand('python', ['../lib/intcode.py', '--intcode', intcode_file, '--input', InputOutputArray],
                    output, [poStderrToOutPut]) then
              else
                writeln(error_runcommand);
                writeln(output)
            end;

          end;
        end;
      end;
    end;
  else
    writeln(error_runcommand);
    writeln(output)


end.
