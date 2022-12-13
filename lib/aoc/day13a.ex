defmodule AOC.Day13a do
  use AOC

  @type ordering :: :ordered | :unordered | :indeterminate
  @type packet :: integer() | list(packet())
  @type packet_pair :: {packet(), packet()}
  @type raw_input :: String.t()

  @spec solution(raw_input()) :: integer()
  def solution(path) do
    path
    |> File.read!()
    |> parse_packet_pairs()
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet_pair, _} -> ordering(packet_pair) == :ordered end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.sum()
  end

  @spec ordering(packet_pair()) :: ordering()
  def ordering({a, b}) when is_integer(a) and is_integer(b) and a < b, do: :ordered
  def ordering({a, b}) when is_integer(a) and is_integer(b) and a == b, do: :indeterminate
  def ordering({a, b}) when is_integer(a) and is_integer(b), do: :unordered
  def ordering({a, b}) when is_integer(a) and is_list(b), do: ordering({[a], b})
  def ordering({a, b}) when is_list(a) and is_integer(b), do: ordering({a, [b]})

  def ordering({a, b}) when is_list(a) and is_list(b) do
    case Enum.zip_reduce(a, b, :indeterminate, fn
           _a, _b, :ordered -> :ordered
           _a, _b, :unordered -> :unordered
           a, b, :indeterminate -> ordering({a, b})
         end) do
      :ordered ->
        :ordered

      :unordered ->
        :unordered

      :indeterminate ->
        cond do
          length(a) < length(b) -> :ordered
          length(a) > length(b) -> :unordered
          true -> :indeterminate
        end
    end
  end

  @spec parse_packet_pairs(raw_input()) :: list(packet_pair())
  def parse_packet_pairs(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_packet_pair/1)
  end

  @spec parse_packet_pair(String.t()) :: packet_pair()
  def parse_packet_pair(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
    |> List.to_tuple()
  end

  @spec parse_packet(String.t()) :: packet()
  def parse_packet(input) do
    input
    |> Code.eval_string()
    |> elem(0)
  end
end
