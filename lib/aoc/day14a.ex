defmodule AOC.Day14a do
  use AOC

  @air " "
  @rock "@"
  @sand "#"
  @sand_x 500

  @type cave_map :: list(list(String.t()))
  @type cave_slice :: {cave_map(), x_transform(), void()}
  @type point :: {integer(), integer()}
  @type raw_input :: String.t()
  @type rock_line :: list(point())
  @type sand :: point()
  @type sand_state :: :falling | :rest | :void
  @type sand_unit :: integer()
  @type void :: point()
  @type x_transform :: integer()

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> parse_rock_lines()
    |> Enum.map(&trace_rock_line/1)
    |> trace_cave_slice()
    |> emit_sand()
  end

  @spec emit_sand(cave_slice(), sand_unit()) :: sand_unit()
  def emit_sand({cave_map, x_transform, void}, sand_unit \\ 0) do
    cave_map
    |> List.replace_at(0, List.replace_at(Enum.at(cave_map, 0), @sand_x - x_transform, @sand))
    |> let_sand_fall({@sand_x - x_transform, 0}, void)
    |> case do
      {cave_map, :rest} -> emit_sand({cave_map, x_transform, void}, sand_unit + 1)
      {_cave_map, :void} -> sand_unit
    end
  end

  @spec let_sand_fall(cave_map(), sand(), void()) :: {cave_map(), sand_state()}
  def let_sand_fall(cave_map, {x, y}, void) do
    cond do
      air?(cave_map, {x, y + 1}, void) ->
        let_sand_fall(cave_map, {x, y + 1}, void)

      void?({x - 1, y + 1}, void) ->
        {cave_map, :void}

      air?(cave_map, {x - 1, y + 1}, void) ->
        let_sand_fall(cave_map, {x - 1, y + 1}, void)

      air?(cave_map, {x + 1, y + 1}, void) ->
        let_sand_fall(cave_map, {x + 1, y + 1}, void)

      true ->
        {List.replace_at(cave_map, y, List.replace_at(Enum.at(cave_map, y), x, @sand)), :rest}
    end
  end

  @spec air?(cave_map(), point(), void()) :: boolean()
  def air?(_cave_map, {x, y}, {vx, vy}) when x < 0 or x > vx or y > vy, do: false

  def air?(cave_map, {x, y}, _void), do: Enum.at(cave_map, y) |> Enum.at(x) == @air

  @spec void?(point(), void()) :: boolean()
  def void?({x, y}, {vx, vy}) when x < 0 or x > vx or y > vy, do: true
  def void?(_, _), do: false

  @spec trace_cave_slice(list(point())) :: cave_slice()
  def trace_cave_slice(points) do
    points =
      points
      |> List.flatten()
      |> Enum.uniq()

    x_transform =
      points
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.min()

    points = Enum.map(points, fn {x, y} -> {x - x_transform, y} end)

    xv =
      points
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.max()

    yv =
      points
      |> Enum.map(fn {_, y} -> y end)
      |> Enum.max()

    cave_map =
      points
      |> initialize_cave_map()
      |> plot_rocks(points)

    {cave_map, x_transform, {xv, yv}}
  end

  @spec plot_rocks(cave_map(), list(point())) :: cave_map()
  def plot_rocks(cave_map, points) do
    Enum.reduce(points, cave_map, fn {x, y}, cave_map ->
      List.replace_at(cave_map, y, List.replace_at(Enum.at(cave_map, y), x, @rock))
    end)
  end

  @spec initialize_cave_map(list(point())) :: cave_map()
  def initialize_cave_map(points) do
    x_values = Enum.map(points, fn {x, _} -> x end)
    y_values = Enum.map(points, fn {_, y} -> y end)
    {min_x, max_x} = {Enum.min(x_values), Enum.max(x_values)}
    {_min_y, max_y} = {Enum.min(y_values), Enum.max(y_values)}
    for _y <- 0..max_y, into: [], do: for(_x <- min_x..max_x, into: [], do: @air)
  end

  @spec trace_rock_line(rock_line(), rock_line()) :: rock_line()
  def trace_rock_line(rock_line, tracing \\ [])
  def trace_rock_line([end_rock], tracing), do: [end_rock | tracing]

  def trace_rock_line([{x, y}, {x, y} | rock_line], tracing),
    do: trace_rock_line([{x, y} | rock_line], [{x, y} | tracing])

  def trace_rock_line([{x1, y}, {x2, y} | rock_line], tracing) when x1 < x2,
    do: trace_rock_line([{x1 + 1, y}, {x2, y} | rock_line], [{x1, y} | tracing])

  def trace_rock_line([{x1, y}, {x2, y} | rock_line], tracing) when x1 > x2,
    do: trace_rock_line([{x1 - 1, y}, {x2, y} | rock_line], [{x1, y} | tracing])

  def trace_rock_line([{x, y1}, {x, y2} | rock_line], tracing) when y1 < y2,
    do: trace_rock_line([{x, y1 + 1}, {x, y2} | rock_line], [{x, y1} | tracing])

  def trace_rock_line([{x, y1}, {x, y2} | rock_line], tracing) when y1 > y2,
    do: trace_rock_line([{x, y1 - 1}, {x, y2} | rock_line], [{x, y1} | tracing])

  @spec parse_rock_lines(list(raw_input())) :: list(rock_line())
  def parse_rock_lines(lines) do
    lines
    |> Enum.map(&String.trim/1)
    |> Enum.map(&split_points/1)
    |> Enum.map(fn raw_points -> Enum.map(raw_points, &parse_point/1) end)
  end

  @spec split_points(raw_input()) :: list(raw_input())
  def split_points(line) do
    String.split(line, " -> ", trim: true)
  end

  @spec parse_point(raw_input()) :: point()
  def parse_point(raw_point) do
    raw_point
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
