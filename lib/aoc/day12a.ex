defmodule AOC.Day12a do
  use AOC
  alias AOC.Day12.AstralPlane

  @type raw_input :: list(String.t())

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> build_elevation_map()
    |> find_trail()

    receive do
      {:astral_walk_complete, _, steps} -> steps
    end
  end

  @spec find_trail(AstralPlane.elevation_map()) :: :ok
  def find_trail(map) do
    sy = Enum.find_index(map, fn row -> Enum.member?(row, AstralPlane.start_elevation()) end)
    sx = Enum.find_index(Enum.at(map, sy), fn cell -> cell == AstralPlane.start_elevation() end)

    AstralPlane.embark(self(), map, {sx, sy})
    :ok
  end

  @spec build_elevation_map(raw_input()) :: AstralPlane.elevation_map()
  def build_elevation_map(raw_input) do
    raw_input
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end
