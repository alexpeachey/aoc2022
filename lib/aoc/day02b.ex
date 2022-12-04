defmodule AOC.Day02b do
  use AOC

  @type points :: integer()
  @type raw_input :: list(String.t())
  @type strategy_guide :: list(String.t())

  @spec solution(String.t()) :: points()
  def solution(path) do
    path
    |> read_lines()
    |> build_strategy_guide()
    |> Enum.map(&determine_points/1)
    |> Enum.sum()
  end

  @spec build_strategy_guide(raw_input()) :: list(strategy_guide())
  def build_strategy_guide(lines) do
    lines
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  @spec determine_points(strategy_guide()) :: points()
  def determine_points(["A", "X"]), do: 3
  def determine_points(["A", "Y"]), do: 4
  def determine_points(["A", "Z"]), do: 8
  def determine_points(["B", "X"]), do: 1
  def determine_points(["B", "Y"]), do: 5
  def determine_points(["B", "Z"]), do: 9
  def determine_points(["C", "X"]), do: 2
  def determine_points(["C", "Y"]), do: 6
  def determine_points(["C", "Z"]), do: 7
end
