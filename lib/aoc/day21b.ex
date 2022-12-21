defmodule AOC.Day21b do
  use AOC

  @type raw_input :: String.t()

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> build_script()
    |> Code.eval_string()

    find_answer(1)
  end

  @spec find_answer(integer()) :: integer()
  def find_answer(n) do
    case AOC.Day21a.Monkeys.root(n) do
      :eq -> n
      :gt -> find_answer(n * 10)
      :lt -> find_answer(div(n, 10), n)
    end
  end

  @spec find_answer(integer(), integer()) :: integer()
  def find_answer(low, high) do
    mid = div(low + high, 2)

    case AOC.Day21a.Monkeys.root(mid) do
      :eq -> mid
      :gt -> find_answer(mid, high)
      :lt -> find_answer(low, mid)
    end
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
        "root: " <>
          <<monkey1::bytes-size(4)>> <> <<_op::bytes-size(3)>> <> <<monkey2::bytes-size(4)>>
      ),
      do: """
        def root(n) do
          a = #{monkey1}(n)
          b = #{monkey2}(n)
          cond do
            a == b -> :eq
            a > b -> :gt
            a < b -> :lt
          end
        end
      """

  # def parse_definition(
  #       "root: " <>
  #         <<monkey1::bytes-size(4)>> <> <<_op::bytes-size(3)>> <> <<monkey2::bytes-size(4)>>
  #     ),
  #     do: "def root(n), do: #{monkey1}(n) == #{monkey2}(n)"

  def parse_definition("humn: " <> _rest), do: "def humn(n), do: n"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " + " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}(n), do: #{monkey1}(n) + #{monkey2}(n)"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " - " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}(n), do: #{monkey1}(n) - #{monkey2}(n)"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " * " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}(n), do: #{monkey1}(n) * #{monkey2}(n)"

  def parse_definition(
        <<monkey::bytes-size(4)>> <>
          ": " <> <<monkey1::bytes-size(4)>> <> " / " <> <<monkey2::bytes-size(4)>>
      ),
      do: "def #{monkey}(n), do: div(#{monkey1}(n), #{monkey2}(n))"

  def parse_definition(<<monkey::bytes-size(4)>> <> ": " <> number),
    do: "def #{monkey}(_n), do: #{String.to_integer(number)}"
end
