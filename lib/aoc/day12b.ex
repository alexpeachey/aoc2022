defmodule AOC.Day12b do
  use AOC
  alias AOC.Day12.AstralPlane

  @type astral_hike :: %{pid() => integer(), pid() => nil}
  @type raw_input :: list(String.t())

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> build_elevation_map()
    |> find_trail_heads()
    |> await_astral_hikes()
    |> Map.values()
    |> Enum.min()
  end

  @spec await_astral_hikes(astral_hike()) :: astral_hike()
  def await_astral_hikes(hikes) do
    receive do
      {:astral_walk_complete, hike, steps} ->
        hikes = Map.put(hikes, hike, steps)

        if projecting?(hikes) do
          await_astral_hikes(hikes)
        else
          hikes
        end
    end
  end

  @spec projecting?(astral_hike()) :: boolean()
  def projecting?(hikes) do
    hikes
    |> Map.values()
    |> Enum.any?(&is_nil/1)
  end

  @spec find_trail_heads(AstralPlane.elevation_map()) :: astral_hike()
  def find_trail_heads(map) do
    map
    |> Enum.map(fn row -> Enum.with_index(row) end)
    |> Enum.with_index()
    |> Enum.map(fn {row, y} -> Enum.map(row, fn {elevation, x} -> {elevation, {x, y}} end) end)
    |> Enum.map(fn row -> Enum.filter(row, &is_low_point?/1) end)
    |> Enum.flat_map(fn row -> Enum.map(row, fn {_, location} -> location end) end)
    |> Enum.map(&AstralPlane.embark(self(), map, &1))
    |> Enum.map(fn {:ok, hike} -> {hike, nil} end)
    |> Map.new()
  end

  @spec is_low_point?({AstralPlane.elevation(), AstralPlane.location()}) :: boolean()
  def is_low_point?({elevation, _}) do
    elevation == "a" || elevation == AstralPlane.start_elevation()
  end

  @spec build_elevation_map(raw_input()) :: AstralPlane.elevation_map()
  def build_elevation_map(raw_input) do
    raw_input
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end
