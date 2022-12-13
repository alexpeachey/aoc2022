defmodule AOC.Day13b do
  use AOC

  @divider_packet_1 [[2]]
  @divider_packet_2 [[6]]

  @type raw_input :: String.t()

  defmodule Packet do
    @type t :: integer() | list(t())
    @type comparison :: :lt | :gt | :eq

    @spec compare(t(), t()) :: comparison()
    def compare(a, b) when is_integer(a) and is_integer(b) and a < b, do: :lt
    def compare(a, b) when is_integer(a) and is_integer(b) and a == b, do: :eq
    def compare(a, b) when is_integer(a) and is_integer(b), do: :gt
    def compare(a, b) when is_integer(a) and is_list(b), do: compare([a], b)
    def compare(a, b) when is_list(a) and is_integer(b), do: compare(a, [b])

    def compare(a, b) when is_list(a) and is_list(b) do
      case Enum.zip_reduce(a, b, :eq, fn
             _a, _b, :lt -> :lt
             _a, _b, :gt -> :gt
             a, b, :eq -> compare(a, b)
           end) do
        :lt ->
          :lt

        :gt ->
          :gt

        :eq ->
          cond do
            length(a) < length(b) -> :lt
            length(a) > length(b) -> :gt
            true -> :eq
          end
      end
    end
  end

  @spec solution(raw_input()) :: integer()
  def solution(path) do
    path
    |> File.read!()
    |> parse_packets()
    |> add_divider_packets()
    |> Enum.sort(Packet)
    |> identify_divider_packets()
    |> Enum.product()
  end

  @spec identify_divider_packets(list(Packet.t())) :: list(integer())
  def identify_divider_packets(packets) do
    index1 = Enum.find_index(packets, &(&1 == @divider_packet_1)) + 1
    index2 = Enum.find_index(packets, &(&1 == @divider_packet_2)) + 1
    [index1, index2]
  end

  @spec add_divider_packets(list(Packet.t())) :: list(Packet.t())
  def add_divider_packets(packets) do
    [@divider_packet_1, @divider_packet_2 | packets]
  end

  @spec parse_packets(raw_input()) :: list(Packet.t())
  def parse_packets(input) do
    input
    |> String.replace("\n\n", "\n")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_packet/1)
  end

  @spec parse_packet(String.t()) :: Packet.t()
  def parse_packet(input) do
    input
    |> Code.eval_string()
    |> elem(0)
  end
end
