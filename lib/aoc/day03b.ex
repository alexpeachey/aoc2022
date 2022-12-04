defmodule AOC.Day03b do
  use AOC

  @type bag :: MapSet.t()
  @type elf_grouping :: list(bag())
  @type elf_grouping_size :: integer()
  @type item :: String.t()
  @type priority :: integer()
  @type raw_input :: list(String.t())

  @priority "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            |> String.split("", trim: true)
            |> Enum.with_index(1)
            |> Map.new()

  @spec solution(path()) :: priority()
  def solution(path) do
    path
    |> read_lines()
    |> inventory_items()
    |> group_bags(3)
    |> find_group_badges()
    |> determine_item_priority()
    |> Enum.sum()
  end

  @spec inventory_items(raw_input()) :: list(bag())
  def inventory_items(input) do
    input
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&MapSet.new/1)
  end

  @spec group_bags(list(bag()), elf_grouping_size()) :: list(elf_grouping())
  def group_bags(bags, grouping_size) do
    Enum.chunk_every(bags, grouping_size)
  end

  @spec find_group_badges(list(elf_grouping())) :: list(item())
  def find_group_badges(groupings) do
    groupings
    |> Enum.map(fn [bag1, bag2, bag3] ->
      MapSet.intersection(MapSet.intersection(bag1, bag2), bag3)
    end)
    |> Enum.map(&MapSet.to_list/1)
    |> Enum.map(&List.first/1)
  end

  @spec determine_item_priority(list(item())) :: list(priority())
  def determine_item_priority(items) do
    Enum.map(items, &Map.get(@priority, &1))
  end
end
