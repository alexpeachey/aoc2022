defmodule AOC.Day14b do
  use AOC

  @air " "
  @rock "@"
  @sand "#"
  @sand_x 500

  @type bounds :: {point(), point()}
  @type cave_map :: list(list(String.t()))
  @type cave_slice :: {cave_map(), bounds()}
  @type point :: {integer(), integer()}
  @type raw_input :: String.t()
  @type rock_line :: list(point())
  @type sand :: point()
  @type sand_state :: :blocking | :falling | :rest | :void
  @type sand_unit :: integer()

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
  def emit_sand({cave_map, {{minx, _}, _} = bounds}, sand_unit \\ 0) do
    cave_map
    |> List.replace_at(0, List.replace_at(Enum.at(cave_map, 0), @sand_x - minx, @sand))
    |> let_sand_fall({@sand_x, 0}, bounds)
    |> case do
      {cave_map, bounds, :rest} -> emit_sand({cave_map, bounds}, sand_unit + 1)
      {_cave_map, _bounds, :blocking} -> sand_unit + 1
    end
  end

  @spec let_sand_fall(cave_map(), sand(), bounds()) :: {cave_map(), bounds(), sand_state()}
  def let_sand_fall(cave_map, {x, y}, {{minx, miny}, {maxx, maxy}} = bounds)
      when x < minx,
      do:
        let_sand_fall(
          expand_cave(cave_map, bounds, :left),
          {x, y},
          {{minx - 1, miny}, {maxx, maxy}}
        )

  def let_sand_fall(cave_map, {x, y}, {{minx, miny}, {maxx, maxy}} = bounds)
      when x >= maxx,
      do:
        let_sand_fall(
          expand_cave(cave_map, bounds, :right),
          {x, y},
          {{minx, miny}, {maxx + 1, maxy}}
        )

  def let_sand_fall(cave_map, {x, y}, {{minx, _}, _} = bounds) do
    cond do
      air?(cave_map, {x, y + 1}, bounds) ->
        let_sand_fall(cave_map, {x, y + 1}, bounds)

      air?(cave_map, {x - 1, y + 1}, bounds) ->
        let_sand_fall(cave_map, {x - 1, y + 1}, bounds)

      air?(cave_map, {x + 1, y + 1}, bounds) ->
        let_sand_fall(cave_map, {x + 1, y + 1}, bounds)

      blocking?({x, y}) ->
        {cave_map, bounds, :blocking}

      true ->
        {set(cave_map, {x - minx, y}, @sand), bounds, :rest}
    end
  end

  @spec air?(cave_map(), point(), bounds()) :: boolean()
  def air?(cave_map, {x, y}, {{minx, _miny}, _}),
    do: Enum.at(Enum.at(cave_map, y), x - minx) == @air

  @spec blocking?(point()) :: boolean()
  def blocking?({@sand_x, 0}), do: true
  def blocking?(_), do: false

  @spec expand_cave(cave_map(), bounds(), :left | :right) :: cave_map()
  def expand_cave(cave_map, {_, {_, maxy}}, :left) do
    cave_map
    |> Enum.map(fn row -> [@air | row] end)
    |> then(fn cave_map ->
      set(cave_map, {0, maxy}, @rock)
    end)
  end

  def expand_cave(cave_map, {{_minx, _}, {_maxx, maxy}}, :right) do
    cave_map
    |> Enum.map(fn row -> Enum.reverse([@air | Enum.reverse(row)]) end)
    |> then(fn cave_map ->
      set(cave_map, {-1, maxy}, @rock)
    end)
  end

  @spec trace_cave_slice(list(point())) :: cave_slice()
  def trace_cave_slice(points) do
    points =
      points
      |> List.flatten()
      |> Enum.uniq()

    minx = points |> Enum.map(fn {x, _} -> x end) |> Enum.min()
    maxx = points |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    miny = 0
    maxy = points |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    maxy = maxy + 2
    bounds = {{minx, miny}, {maxx, maxy}}
    floor = trace_rock_line([{minx, maxy}, {maxx, maxy}])
    points = points ++ floor

    cave_map =
      bounds
      |> initialize_cave_map()
      |> plot_rocks(points, bounds)

    {cave_map, bounds}
  end

  @spec plot_rocks(cave_map(), list(point()), bounds()) :: cave_map()
  def plot_rocks(cave_map, points, {{minx, _}, _}) do
    Enum.reduce(points, cave_map, fn {x, y}, cave_map ->
      set(cave_map, {x - minx, y}, @rock)
    end)
  end

  @spec initialize_cave_map(bounds()) :: cave_map()
  def initialize_cave_map({{minx, miny}, {maxx, maxy}}) do
    for _y <- miny..maxy, into: [], do: for(_x <- minx..maxx, into: [], do: @air)
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

  @spec set(cave_map(), point(), String.t()) :: cave_map()
  def set(cave_map, {x, y}, formation) do
    List.replace_at(cave_map, y, List.replace_at(Enum.at(cave_map, y), x, formation))
  end

  @spec print_map(cave_map()) :: cave_map()
  def print_map(cave_map) do
    cave_map
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()

    cave_map
  end
end
