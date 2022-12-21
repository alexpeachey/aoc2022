defmodule AOC.Day21a do
  use AOC

  @type raw_input :: String.t()

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> build_script()
    |> Code.eval_string()

    AOC.Day21a.Monkeys.root()
  end

  @spec build_script(list(raw_input())) :: String.t()
  def build_script(definitions) do
    monkeys =
      definitions
      |> Enum.map(&parse_definition/1)
      |> Enum.join("\n")

    "defmodule AOC.Day21a.Monkeys do\n" <> monkeys <> "\nend\n"
  end

  @spec parse_definition(raw_input()) :: String.t()
  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " + " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}, do: #{monkey1}() + #{monkey2}()"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " - " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}, do: #{monkey1}() - #{monkey2}()"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " * " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}, do: #{monkey1}() * #{monkey2}()"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " / " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}, do: div(#{monkey1}(), #{monkey2}())"

  def parse_definition(<<monkey::bytes-size(4)>> <> ": " <> number),
    do: "def #{monkey}, do: #{String.to_integer(number)}"
end
