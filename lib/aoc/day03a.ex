defmodule AOC.Day03a do
  use AOC

  @type bag :: list(compartment())
  @type compartment :: String.t()
  @type inventoried_bag :: list(inventoried_compartment())
  @type inventoried_compartment :: MapSet.t()
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
    |> build_bags_with_compartments()
    |> inventory_items()
    |> find_common_items_from_compartments()
    |> determine_item_priority()
    |> Enum.sum()
  end

  @spec build_bags_with_compartments(raw_input()) :: list(bag())
  def build_bags_with_compartments(bags) do
    bags
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split_at(&1, div(String.length(&1), 2)))
    |> Enum.map(&Tuple.to_list/1)
  end

  @spec inventory_items(list(bag())) :: list(inventoried_bag())
  def inventory_items(bags) do
    bags
    |> Enum.map(fn compartments -> Enum.map(compartments, &String.split(&1, "", trim: true)) end)
    |> Enum.map(fn compartments -> Enum.map(compartments, &MapSet.new/1) end)
  end

  @spec find_common_items_from_compartments(list(inventoried_bag())) :: list(item())
  def find_common_items_from_compartments(bags) do
    bags
    |> Enum.map(fn [compartment1, compartment2] ->
      MapSet.intersection(compartment1, compartment2)
    end)
    |> Enum.map(&MapSet.to_list/1)
    |> Enum.map(&List.first/1)
  end

  @spec determine_item_priority(list(item())) :: list(priority())
  def determine_item_priority(items) do
    Enum.map(items, &Map.get(@priority, &1))
  end
end
