defmodule AOC.Day03a do
  use AOC

  @priority "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            |> String.split("", trim: true)
            |> Enum.with_index(1)
            |> Map.new()

  @spec solution(String.t()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split_at(&1, div(String.length(&1), 2)))
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn bags -> Enum.map(bags, &String.split(&1, "", trim: true)) end)
    |> Enum.map(fn bags -> Enum.map(bags, &MapSet.new/1) end)
    |> Enum.map(fn [bag1, bag2] -> MapSet.intersection(bag1, bag2) end)
    |> Enum.map(&MapSet.to_list/1)
    |> Enum.map(&List.first/1)
    |> Enum.map(&Map.get(@priority, &1))
    |> Enum.sum()
  end
end
