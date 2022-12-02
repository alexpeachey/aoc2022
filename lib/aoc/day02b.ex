defmodule AOC.Day02b do
  use AOC

  @spec solution(String.t()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(&points/1)
    |> Enum.sum()
  end

  @spec points([String.t()]) :: integer()
  def points(["A", "X"]), do: 3
  def points(["A", "Y"]), do: 4
  def points(["A", "Z"]), do: 8
  def points(["B", "X"]), do: 1
  def points(["B", "Y"]), do: 5
  def points(["B", "Z"]), do: 9
  def points(["C", "X"]), do: 2
  def points(["C", "Y"]), do: 6
  def points(["C", "Z"]), do: 7
end
