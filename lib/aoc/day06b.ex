defmodule AOC.Day06b do
  use AOC

  @marker_length 14

  @type buffer :: list(String.t())
  @type character_count :: integer()
  @type raw_input :: String.t()

  @spec solution(path()) :: character_count()
  def solution(path) do
    path
    |> File.read!()
    |> craft_buffer()
    |> identify_marker()
    |> length()
  end

  @spec craft_buffer(raw_input()) :: buffer()
  def craft_buffer(raw_input) do
    String.split(raw_input, "", trim: true)
  end

  @spec identify_marker(buffer(), buffer()) :: buffer()
  def identify_marker(buffer, consumed \\ [])

  def identify_marker([character | rest], consumed) when length(consumed) < @marker_length,
    do: identify_marker(rest, [character | consumed])

  def identify_marker([character | rest], consumed) do
    marker = Enum.take(consumed, @marker_length)

    if Enum.uniq(marker) == marker do
      consumed
    else
      identify_marker(rest, [character | consumed])
    end
  end
end
