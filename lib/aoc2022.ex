defmodule AOC do
  @moduledoc """
  Documentation for `AOC`.
  This file provides basic helper functions for the Advent of Code 2022.
  """

  defmacro __using__(_opts) do
    quote do
      import AOC
      @behaviour AOC
    end
  end

  @doc """
  Returns the solution for a puzzle.
  """
  @callback solution(String.t()) :: any()

  @doc """
  Returns the input for the given day as a list of strings.
  """
  @spec read_lines(String.t()) :: list(String.t())
  def read_lines(filename) do
    filename
    |> File.stream!()
    |> Stream.reject(&(&1 == ""))
    |> Enum.to_list()
  end
end
