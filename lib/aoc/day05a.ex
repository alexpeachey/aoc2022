defmodule AOC.Day05a do
  use AOC

  @type crate :: String.t()
  @type top_crates :: list(crate())
  @type instruction :: %{count: integer(), from: integer(), to: integer()}
  @type procedure :: list(instruction())
  @type raw_crate :: list(String.t())
  @type raw_input :: String.t()
  @type result() :: String.t()
  @type simple_crate() :: String.t()
  @type stack :: list(crate())
  @type ship :: %{integer() => stack()}

  @spec solution(path()) :: result()
  def solution(path) do
    [raw_stacks, raw_procedure] =
      path
      |> File.read!()
      |> parse_stacks_and_procedure()

    ship = parse_stacks(raw_stacks)
    procedure = parse_procedure(raw_procedure)

    ship
    |> execute_procedure(procedure)
    |> top_crates()
    |> Enum.join()
  end

  @spec top_crates(ship()) :: top_crates()
  def top_crates(ship) do
    ship
    |> Map.values()
    |> Enum.map(&hd/1)
  end

  @spec execute_procedure(ship(), procedure()) :: ship()
  def execute_procedure(ship, procedure) do
    Enum.reduce(procedure, ship, &execute_instruction/2)
  end

  @spec execute_instruction(instruction(), ship()) :: ship()
  def execute_instruction(instruction, ship) do
    {from, to} = move_crates(ship[instruction.from], ship[instruction.to], instruction.count)
    Map.merge(ship, %{instruction.from => from, instruction.to => to})
  end

  @spec move_crates(stack(), stack(), integer()) :: {stack(), stack()}
  def move_crates(from, to, count) do
    {Enum.drop(from, count), stack_crates(Enum.take(from, count), to)}
  end

  @spec stack_crates(list(crate()), stack()) :: stack()
  def stack_crates([], stack), do: stack
  def stack_crates([crate | rest], stack), do: stack_crates(rest, [crate | stack])

  @spec parse_procedure(raw_input()) :: procedure()
  def parse_procedure(raw_procedure) do
    raw_procedure
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  @spec parse_instruction(raw_input()) :: instruction()
  def parse_instruction(input) do
    ~r/^move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)$/
    |> Regex.named_captures(input)
    |> Enum.map(fn {key, value} -> {String.to_atom(key), String.to_integer(value)} end)
    |> Map.new()
  end

  @spec parse_stacks_and_procedure(raw_input()) :: [raw_input()]
  def parse_stacks_and_procedure(input) do
    String.split(input, "\n\n", trim: true)
  end

  @spec parse_stacks(raw_input()) :: ship()
  def parse_stacks(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&parse_raw_crates/1)
    |> transpose()
    |> Enum.map(&simplify_crates/1)
    |> initialize_ship()
  end

  @spec initialize_ship(list(stack())) :: ship()
  def initialize_ship(stacks) do
    stacks
    |> Enum.map(fn [stack_number | crates] ->
      {String.to_integer(stack_number), stack_top_to_bottom(crates)}
    end)
    |> Map.new()
  end

  @spec stack_top_to_bottom(stack()) :: stack()
  def stack_top_to_bottom(stack) do
    Enum.reverse(stack)
  end

  @spec parse_raw_crates(list(String.t())) :: list(raw_crate())
  def parse_raw_crates(row) do
    Enum.chunk_every(row, 4)
  end

  @spec simplify_crates(list(raw_crate())) :: list(crate())
  def simplify_crates(crates) do
    crates
    |> Enum.map(fn crate -> Enum.at(crate, 1) end)
    |> Enum.reject(&(&1 == " "))
  end

  @spec transpose(list(String.t())) :: list(String.t())
  def transpose(list) do
    list
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
