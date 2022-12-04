defmodule AOC.Day04a do
  use AOC

  @spec solution(String.t()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn elves -> Enum.map(elves, &String.split(&1, "-")) end)
    |> Enum.map(fn elves -> Enum.map(elves, fn elf -> Enum.map(elf, &String.to_integer/1) end) end)
    |> Enum.map(fn elves -> Enum.map(elves, fn [low, high] -> MapSet.new(low..high) end) end)
    |> Enum.reject(fn [elf1, elf2] -> MapSet.disjoint?(elf1, elf2) end)
    |> Enum.filter(fn [elf1, elf2] -> MapSet.subset?(elf1, elf2) || MapSet.subset?(elf2, elf1) end)
    |> Enum.count()
  end
end
