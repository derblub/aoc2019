# https://adventofcode.com/2019/day/18

#    elixir main.exs


defmodule Main do


  def get_input(name) do
    File.read!(name)
      |> String.trim
  end

  def modify_input(input) do
    # modify the center of the maze make it 4 bots
    # instead of 1 and split the maze to 4 zones
    input
      |> String.replace(~r/.@./, "###")
      |> String.replace(~r/^(.{3237})(\.{3})(.*)/s, "\\1@#@\\3")
      |> String.replace(~r/^(.{3401})(\.{3})(.*)/s, "\\1@#@\\3")
  end


  def step1(input) do
    points =
      for {line, y} <- String.trim(input) |> String.split("\n") |> Enum.with_index(),
          {c, x} <- String.codepoints(line) |> Enum.with_index(),
          do: {{x, y}, c}

    {start, _} = Enum.find(points, fn {_, c} -> c == "@" end)
    keys = Enum.count(points, fn {_, c} -> c =~ ~r([a-z]) end)
    Map.new(points) |> Main.maze(start, keys)
  end


  def step2(input) do
    points =
      for {line, y} <- String.trim(input) |> String.split("\n") |> Enum.with_index(),
          {c, x} <- String.codepoints(line) |> Enum.with_index(),
          do: {{x, y}, c}

    start_target = Enum.filter(points, fn {_, c} -> c == "@" end) |> Enum.map(fn {point, _} -> point end)
    keys = Enum.count(points, fn {_, c} -> c =~ ~r([a-z]) end)
    Map.new(points) |> Main.maze_part2(start_target, keys)

  end


  def neighbour({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]


  def maze(map, start, keys_count) do
    maze(map, keys_count, MapSet.new([{start, MapSet.new()}]), :queue.from_list([{start, MapSet.new(), 0}]))
  end


  def maze(map, keys_count, visit_cache, queue) do
    {{:value, {current_target, keys, depth}}, queue} = :queue.out(queue)

    if MapSet.size(keys) == keys_count do depth
    else
      {visit_cache, queue} =
        Main.neighbour(current_target)
        |> Enum.reduce({visit_cache, queue}, fn new_target, unmodified = {visit_cache, queue} ->
          modify = &modify(visit_cache, queue, new_target, depth + 1, &1)

          case map[new_target] do
            "#" -> unmodified
            "." -> modify.(keys)
            "@" -> modify.(keys)
              x ->
              cond do
                x =~ ~r([a-z]) -> MapSet.put(keys, String.upcase(x)) |> modify.()
                x =~ ~r([A-Z]) -> if MapSet.member?(keys, x), do: modify.(keys), else: unmodified
              end
          end
        end)

      maze(map, keys_count, visit_cache, queue)
    end
  end


  def modify(visit_cache, queue, new_target, new_depth, keys) do
    if MapSet.member?(visit_cache, {new_target, keys}) do
      {visit_cache, queue}
    else
      visit_cache = MapSet.put(visit_cache, {new_target, keys})
      queue = :queue.in({new_target, keys, new_depth}, queue)
      {visit_cache, queue}
    end
  end

  def maze_part2(map, start_target, keys_count) do
    start_target = Enum.map(start_target, &{&1, Enum.sort(start_target -- [&1])})
    queue = Enum.map(start_target, fn {pos, all_bots} -> {pos, MapSet.new(), all_bots, 0} end)
      |> :queue.from_list()
    maze_part2(map, keys_count, MapSet.new(start_target), queue)
  end


  def maze_part2(map, keys_count, visit_cache, queue) do
    {{:value, {current_target, keys, all_bots, depth}}, queue} = :queue.out(queue)

    if MapSet.size(keys) == keys_count do depth
    else
      {visit_cache, queue} =
        Main.neighbour(current_target)
        |> Enum.reduce({visit_cache, queue}, fn new_target, unmodified = {visit_cache, queue} ->
          modify = &modify(visit_cache, queue, new_target, depth + 1, &1, all_bots)

          case map[new_target] do
            "#" -> unmodified
            "." -> modify.(keys)
            "@" -> modify.(keys)
              x ->
              cond do
                x =~ ~r([a-z]) ->
                  inserted_key = MapSet.put(keys, String.upcase(x))
                  all_robots = [new_target | all_bots]

                  Enum.reduce(all_robots, {visit_cache, queue}, fn robot_pos, {visit_cache, queue} ->
                    modify(visit_cache, queue, robot_pos, depth + 1, inserted_key, Enum.sort(all_robots -- [robot_pos]))
                  end)

                x =~ ~r([A-Z]) -> if MapSet.member?(keys, x), do: modify.(keys), else: unmodified
              end
          end
        end)

      maze_part2(map, keys_count, visit_cache, queue)
    end
  end


  def modify(visit_cache, queue, new_target, new_depth, keys, all_bots) do
    if MapSet.member?(visit_cache, {new_target, keys, all_bots}) do
      {visit_cache, queue}
    else
      visit_cache = MapSet.put(visit_cache, {new_target, keys, all_bots})
      queue = :queue.in({new_target, keys, all_bots, new_depth}, queue)
      {visit_cache, queue}
    end
  end


end

Main.get_input("input.txt") |> Main.step1 |> IO.puts
Main.get_input("input.txt") |> Main.modify_input |> Main.step2 |> IO.inspect
