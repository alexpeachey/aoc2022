defmodule AOC.Day10b do
  use AOC

  @type addx :: {:addx, integer()}
  @type cpu :: list(cpu_state())
  @type cpu_state :: {cycle(), xregister_begin(), xregister_end()}
  @type crt :: list(crt_row())
  @type crt_row :: list(String.t())
  @type cursor() :: integer()
  @type cycle :: integer()
  @type instruction :: noop() | addx()
  @type noop :: :noop
  @type raw_input :: String.t()
  @type sprite :: Range.t()
  @type xregister :: integer()
  @type xregister_begin :: xregister()
  @type xregister_end :: xregister()

  @spec solution(path()) :: :ok
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_instruction/1)
    |> Enum.reduce([{0, 1, 1}], &execute/2)
    |> Enum.reverse()
    |> Enum.reduce(init_crt(), &draw/2)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.join("\n")
    |> IO.puts()
  end

  @spec draw(cpu(), crt()) :: crt()
  def draw([], crt), do: crt
  def draw([{0, _, _} | _], crt), do: crt

  def draw({cycle, x, _}, crt) do
    row = div(cycle - 1, 40)
    col = rem(cycle - 1, 40)

    if Enum.member?(sprite(x), col) do
      List.replace_at(crt, row, List.replace_at(Enum.at(crt, row), col, "#"))
    else
      crt
    end
  end

  @spec sprite(xregister()) :: sprite()
  def sprite(x), do: (x - 1)..(x + 1)

  @spec init_crt() :: crt()
  def init_crt() do
    Enum.map(1..6, fn _ -> Enum.map(1..40, fn _ -> "." end) end)
  end

  @spec execute(instruction(), cpu()) :: cpu()
  def execute(:noop, [{cycle, _b, e} | _] = cpu), do: [{cycle + 1, e, e} | cpu]

  def execute({:addx, x}, [{cycle, _b, e} | _] = cpu),
    do: [{cycle + 2, e, e + x}, {cycle + 1, e, e} | cpu]

  @spec parse_instruction(raw_input()) :: instruction()
  def parse_instruction("noop"), do: :noop
  def parse_instruction("addx " <> x), do: {:addx, String.to_integer(x)}
end
