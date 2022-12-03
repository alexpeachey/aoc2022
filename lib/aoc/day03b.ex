defmodule AOC.Day03b do
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
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&MapSet.new/1)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [bag1, bag2, bag3] ->
      MapSet.intersection(MapSet.intersection(bag1, bag2), bag3)
    end)
    |> Enum.map(&MapSet.to_list/1)
    |> Enum.map(&List.first/1)
    |> Enum.map(&Map.get(@priority, &1))
    |> Enum.sum()
  end
end
