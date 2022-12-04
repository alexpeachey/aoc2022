defmodule AOC.Day01a do
  use AOC

  @type calories :: integer()
  @type food_pack :: String.t()
  @type raw_input :: String.t()

  @spec solution(path()) :: calories()
  def solution(path) do
    path
    |> File.read!()
    |> divide_food_packs()
    |> combine_calories()
    |> determine_highest()
  end

  @spec divide_food_packs(raw_input()) :: list(food_pack())
  def divide_food_packs(input) do
    String.split(input, "\n\n", trim: true)
  end

  @spec combine_calories(list(food_pack())) :: list(calories())
  def combine_calories(food_packs) do
    food_packs
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn foods -> Enum.map(foods, &String.to_integer/1) end)
    |> Enum.map(&Enum.sum/1)
  end

  @spec determine_highest(list(calories())) :: calories()
  def determine_highest(calories) do
    calories
    |> Enum.sort(:desc)
    |> hd()
  end
end
