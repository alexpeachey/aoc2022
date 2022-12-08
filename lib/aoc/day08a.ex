defmodule AOC.Day08a do
  use AOC

  @type direction :: :north | :south | :east | :west
  @type forest :: list(indexed_row())
  @type forest_visibility :: list(list(visibility()))
  @type index :: integer()
  @type indexed_row :: list(indexed_tree())
  @type indexed_tree :: {tree(), {xindex(), yindex()}}
  @type raw_input :: list(String.t())
  @type row() :: list(tree())
  @type row_visibility() :: list(visibility())
  @type tree :: integer()
  @type tree_count :: integer()
  @type visibility :: :visible | :obstructed
  @type xindex :: index()
  @type yindex :: index()

  @spec solution(path()) :: tree_count()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)
    |> Enum.with_index()
    |> Enum.map(&add_tree_coordinates/1)
    |> set_forest_visibility()
    |> Enum.map(&survey_row/1)
    |> Enum.sum()
  end

  @spec survey_row(row_visibility()) :: tree_count()
  def survey_row(row) do
    Enum.count(row, &(&1 == :visible))
  end

  @spec set_forest_visibility(forest()) :: forest_visibility()
  def set_forest_visibility(forest) do
    Enum.map(forest, &determine_visibility(&1, forest))
  end

  @spec determine_visibility(indexed_row(), forest()) :: list(visibility())
  def determine_visibility(row, forest) do
    Enum.map(row, fn {tree, {x, y}} -> determine_visibility(tree, x, y, forest) end)
  end

  @spec determine_visibility(tree(), xindex(), yindex(), forest()) :: visibility()
  def determine_visibility(_tree, 0, _y, _forest), do: :visible
  def determine_visibility(_tree, _x, 0, _forest), do: :visible
  def determine_visibility(_tree, x, _y, [row | _]) when x == length(row) - 1, do: :visible
  def determine_visibility(_tree, _X, y, forest) when y == length(forest) - 1, do: :visible

  def determine_visibility(tree, x, y, forest) do
    if visible?(tree, trees_in_direction(:north, x, y - 1, forest, [])) ||
         visible?(tree, trees_in_direction(:south, x, y + 1, forest, [])) ||
         visible?(tree, trees_in_direction(:east, x + 1, y, forest, [])) ||
         visible?(tree, trees_in_direction(:west, x - 1, y, forest, [])) do
      :visible
    else
      :obstructed
    end
  end

  @spec visible?(tree(), list(tree())) :: boolean()
  def visible?(tree, trees) do
    Enum.all?(trees, &(&1 < tree))
  end

  @spec trees_in_direction(direction(), xindex(), yindex(), forest(), list(tree())) ::
          list(tree())
  def trees_in_direction(_direction, x, 0, forest, trees), do: [tree_at(forest, x, 0) | trees]
  def trees_in_direction(_direction, 0, y, forest, trees), do: [tree_at(forest, 0, y) | trees]

  def trees_in_direction(_direction, x, y, [row | _] = forest, trees) when x == length(row) - 1,
    do: [tree_at(forest, x, y) | trees]

  def trees_in_direction(_direction, x, y, forest, trees) when y == length(forest) - 1,
    do: [tree_at(forest, x, y) | trees]

  def trees_in_direction(:north, x, y, forest, trees),
    do: trees_in_direction(:north, x, y - 1, forest, [tree_at(forest, x, y) | trees])

  def trees_in_direction(:south, x, y, forest, trees),
    do: trees_in_direction(:south, x, y + 1, forest, [tree_at(forest, x, y) | trees])

  def trees_in_direction(:east, x, y, forest, trees),
    do: trees_in_direction(:east, x + 1, y, forest, [tree_at(forest, x, y) | trees])

  def trees_in_direction(:west, x, y, forest, trees),
    do: trees_in_direction(:west, x - 1, y, forest, [tree_at(forest, x, y) | trees])

  @spec tree_at(forest(), xindex(), yindex()) :: tree()
  def tree_at(forest, x, y) do
    forest
    |> Enum.at(y)
    |> Enum.at(x)
    |> elem(0)
  end

  @spec add_tree_coordinates({row(), yindex()}) :: indexed_row()
  def add_tree_coordinates({row, y}) do
    row
    |> Enum.with_index()
    |> Enum.map(fn {tree, x} -> {tree, {x, y}} end)
  end
end
