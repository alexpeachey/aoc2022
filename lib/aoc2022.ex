defmodule AOC do
  @moduledoc """
  Documentation for `AOC`.
  This file provides basic helper functions for the Advent of Code 2022.
  """

  @type path :: String.t()

  defmacro __using__(_opts) do
    quote do
      import AOC
      @behaviour AOC
      @type path :: String.t()
    end
  end

  @doc """
  Returns the solution for a puzzle.
  """
  @callback solution(path()) :: any()

  @doc """
  Returns the input for the given day as a list of strings.
  """
  @spec read_lines(path()) :: list(String.t())
  def read_lines(filename) do
    filename
    |> File.stream!()
    |> Enum.to_list()
  end
end
