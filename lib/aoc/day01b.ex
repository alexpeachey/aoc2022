defmodule AOC.Day01b do
  use AOC

  @spec solution(String.t()) :: integer()
  def solution(path) do
    path
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn elf -> Enum.map(elf, &String.to_integer/1) end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end
end
