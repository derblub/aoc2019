#!/usr/bin/env escript

 % https://adventofcode.com/2019/day/6

 -mode(native).

 main(Args) ->
  Input = load_input("input.txt"),
  Data = orbit(Input),
  Sol =
    case Args of
      ["2"] -> tosanta(Data);
          _ -> count_total(Data)
    end,
  io:format("~w~n", [Sol]).

load_input(Filename) ->
  {ok, File} = file:open(Filename, [read]),
  Data = read_file(File),
  ok = file:close(File),
  Data.

read_file(File) ->
  read_file(File, []).

read_file(File, Data) ->
  case io:fread(File, "", "~s") of
    {ok, Res} -> read_file(File, [Res|Data]);
    eof -> lists:reverse(Data)
  end.

orbit(Input) ->
  orbit(Input, #{}).

orbit([], Map) -> Map;
orbit([[Line]|Rest], Map) ->
  [Center, Orbiter] = string:tokens(Line, ")"),
  NewMap = Map#{Orbiter => Center},
  orbit(Rest, NewMap).

count_total(Data) ->
  Keys = maps:keys(Data),
  count_total(Keys, Data, 0).

count_total([], _, N) -> N;
count_total([Key|Rest], Data, N) ->
  I = find_orbit_root(Key, Data),
  count_total(Rest, Data, N + I).

find_orbit_root(Key, Data) ->
  find_orbit_root(Key, Data, 0).

find_orbit_root(Key, Data, N) ->
  case maps:get(Key, Data, none) of
    none -> N;
    New  -> find_orbit_root(New, Data, N + 1)
  end.

tosanta(Data) ->
  You = path("YOU", Data),
  San = path("SAN", Data),
  YouLen = length(You -- San),
  SanLen = length(San -- You),
  YouLen + SanLen - 2.

path(Target, Data) ->
  path(Target, Data, [Target]).

path(Target, Data, Acc) ->
  case maps:get(Target, Data, none) of
    none -> Acc;
    New  -> path(New, Data, [New|Acc])
  end.
