defmodule AOC.Day08b do
  use AOC

  @type direction :: :north | :south | :east | :west
  @type forest :: list(indexed_row())
  @type index :: integer()
  @type indexed_row :: list(indexed_tree())
  @type indexed_tree :: {tree(), {xindex(), yindex()}}
  @type raw_input :: list(String.t())
  @type row() :: list(tree())
  @type scenic_score :: integer()
  @type scored_forest :: list(list(scenic_score()))
  @type tree :: integer()
  @type tree_count :: integer()
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
    |> score_forest()
    |> List.flatten()
    |> Enum.max()
  end

  @spec score_forest(forest()) :: scored_forest()
  def score_forest(forest) do
    Enum.map(forest, &determine_scenic_score(&1, forest))
  end

  @spec determine_scenic_score(indexed_row(), forest()) :: list(scenic_score())
  def determine_scenic_score(row, forest) do
    Enum.map(row, fn {tree, {x, y}} -> determine_scenic_score(tree, x, y, forest) end)
  end

  @spec determine_scenic_score(tree(), xindex(), yindex(), forest()) :: scenic_score()
  def determine_scenic_score(tree, x, y, forest) do
    score_view(tree, trees_in_direction(:north, x, y - 1, forest, [])) *
      score_view(tree, trees_in_direction(:south, x, y + 1, forest, [])) *
      score_view(tree, trees_in_direction(:east, x + 1, y, forest, [])) *
      score_view(tree, trees_in_direction(:west, x - 1, y, forest, []))
  end

  @spec score_view(tree, list(tree())) :: scenic_score()
  def score_view(tree, trees) do
    trees
    |> Enum.reverse()
    |> Enum.find_index(&(&1 >= tree))
    |> case do
      nil -> length(trees)
      index -> index + 1
    end
  end

  @spec trees_in_direction(direction(), xindex(), yindex(), forest(), list(tree())) ::
          list(tree())
  def trees_in_direction(_direction, _x, -1, _forest, []), do: []
  def trees_in_direction(_direction, -1, _y, _forest, []), do: []
  def trees_in_direction(_direction, x, _y, [row | _], []) when x == length(row), do: []
  def trees_in_direction(_direction, _x, y, forest, []) when y == length(forest), do: []
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
