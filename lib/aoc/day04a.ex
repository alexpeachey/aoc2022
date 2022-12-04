defmodule AOC.Day04a do
  use AOC

  @type elf_pair_with_sector_assignments :: list(sector_assignment())
  @type elf_pair :: list(String.t())
  @type overlapping_assignment_count :: integer()
  @type raw_input :: list(String.t())
  @type sector_assignment :: MapSet.t()

  @spec solution(String.t()) :: overlapping_assignment_count()
  def solution(path) do
    path
    |> read_lines()
    |> pair_elves()
    |> parse_sector_assignments()
    |> Enum.reject(&independent_sectors?/1)
    |> Enum.filter(&complete_assignment_overlap?/1)
    |> Enum.count()
  end

  @spec pair_elves(raw_input()) :: list(elf_pair())
  def pair_elves(input) do
    input
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, ","))
  end

  @spec parse_sector_assignments(list(elf_pair())) :: list(elf_pair_with_sector_assignments())
  def parse_sector_assignments(elf_pairs) do
    elf_pairs
    |> Enum.map(fn elves -> Enum.map(elves, &String.split(&1, "-")) end)
    |> Enum.map(fn elves -> Enum.map(elves, fn elf -> Enum.map(elf, &String.to_integer/1) end) end)
    |> Enum.map(fn elves -> Enum.map(elves, fn [low, high] -> MapSet.new(low..high) end) end)
  end

  @spec independent_sectors?(elf_pair_with_sector_assignments()) :: boolean()
  def independent_sectors?([elf1, elf2]) do
    MapSet.disjoint?(elf1, elf2)
  end

  @spec complete_assignment_overlap?(elf_pair_with_sector_assignments()) :: boolean()
  def complete_assignment_overlap?([elf1, elf2]) do
    MapSet.subset?(elf1, elf2) || MapSet.subset?(elf2, elf1)
  end
end
