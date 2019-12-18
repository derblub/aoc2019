# https://adventofcode.com/2019/day/18

#    elixir main.exs


defmodule Main do

  def get_input do
    File.read!("input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> list_of_lists_to_map_by_point
  end

  def parse_line(line) do
    line
    |> String.graphemes
    |> Enum.map(fn
      "#" -> :wall
      "." -> :open
      "@" -> :start
      char -> if String.upcase(char) == char, do: {:door, char}, else: {:key, String.upcase(char)}
    end)
  end

  def list_of_lists_to_map_by_point(list_of_lists) do
    list_of_lists
    |> Stream.with_index
    |> Stream.flat_map(&row_to_point_value_pair/1)
    |> Enum.into(%{})
  end

  def row_to_point_value_pair({row, row_number}) do
    row
    |> Stream.with_index
    |> Stream.map(fn {value, x} -> {{x, row_number}, value} end)
  end


end

IO.inspect Main.get_input
