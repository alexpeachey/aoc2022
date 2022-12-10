defmodule AOC.Day10a do
  use AOC

  @type addx :: {:addx, integer()}
  @type cpu :: list(cpu_state())
  @type cpu_state :: {cycle(), xregister_begin(), xregister_end()}
  @type cycle :: integer()
  @type instruction :: noop() | addx()
  @type noop :: :noop
  @type raw_input :: String.t()
  @type signal_strength :: integer()
  @type xregister :: integer()
  @type xregister_begin :: xregister()
  @type xregister_end :: xregister()

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_instruction/1)
    |> Enum.reduce([{0, 1, 1}], &execute/2)
    |> Enum.reverse()
    |> Enum.map(&compute_signal_strength/1)
    |> sample_signal_strength()
  end

  @spec sample_signal_strength([signal_strength()]) :: signal_strength()
  def sample_signal_strength(signal_strengths) do
    Enum.at(signal_strengths, 20) +
      Enum.at(signal_strengths, 60) +
      Enum.at(signal_strengths, 100) +
      Enum.at(signal_strengths, 140) +
      Enum.at(signal_strengths, 180) +
      Enum.at(signal_strengths, 220)
  end

  @spec compute_signal_strength(cpu_state()) :: signal_strength()
  def compute_signal_strength({cycle, xregister_b, _xregister_e}), do: cycle * xregister_b

  @spec execute(instruction(), cpu()) :: cpu()
  def execute(:noop, [{cycle, _b, e} | _] = cpu), do: [{cycle + 1, e, e} | cpu]

  def execute({:addx, x}, [{cycle, _b, e} | _] = cpu),
    do: [{cycle + 2, e, e + x}, {cycle + 1, e, e} | cpu]

  @spec parse_instruction(raw_input()) :: instruction()
  def parse_instruction("noop"), do: :noop
  def parse_instruction("addx " <> x), do: {:addx, String.to_integer(x)}
end
