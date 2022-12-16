defmodule AOC.Day15b do
  use AOC

  @min 0
  @max 4_000_000
  @freq 4_000_000

  @type beacon :: point()
  @type distance :: integer()
  @type point :: {integer(), integer()}
  @type raw_input :: String.t()
  @type reading :: {sensor(), beacon(), distance()}
  @type sensor :: point()

  @spec solution(path()) :: integer()
  def solution(path) do
    path
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_sensor_info/1)
    |> vertical_scan()
    |> IO.inspect()
    |> then(fn {x, y} -> x * @freq + y end)
  end

  @spec vertical_scan(list(reading())) :: point()
  def vertical_scan(readings) do
    @min..@max
    |> Enum.reduce_while(nil, fn y, _ ->
      case determine_coverage(readings, y) do
        [_..x, _] -> {:halt, {x + 1, y}}
        _ -> {:cont, nil}
      end
    end)
  end

  @spec determine_coverage(list(reading()), integer()) :: list(Range.t())
  def determine_coverage(readings, y) do
    readings
    |> Enum.filter(fn {{_sx, sy}, _, distance} ->
      y <= sy + distance && y >= sy - distance
    end)
    |> Enum.map(fn {{sx, sy}, _, distance} ->
      distance = distance - abs(sy - y)
      max(sx - distance, @min)..min(sx + distance, @max)
    end)
    |> Enum.sort()
    |> simplify_coverage()
  end

  @spec simplify_coverage(list(Range.t())) :: list(Range.t())
  def simplify_coverage([coverage]), do: [coverage]

  def simplify_coverage([coverage1, coverage2 | coverages]) do
    if Range.disjoint?(coverage1, coverage2) do
      [coverage1 | simplify_coverage([coverage2 | coverages])]
    else
      simplify_coverage([merge(coverage1, coverage2) | coverages])
    end
  end

  @spec merge(Range.t(), Range.t()) :: Range.t()
  def merge(a..b, c..d), do: min(a, c)..max(b, d)

  @spec take_a_taxi(point(), point()) :: distance()
  def take_a_taxi({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  @spec parse_sensor_info(raw_input()) :: reading()
  def parse_sensor_info(raw_input) do
    [raw_sensor, raw_beacon] = String.split(raw_input, ": ", trim: true)
    [raw_sensor_x, raw_sensor_y] = String.split(raw_sensor, ", ", trim: true)
    [raw_beacon_x, raw_beacon_y] = String.split(raw_beacon, ", ", trim: true)
    sensor_x = parse_raw_number(raw_sensor_x, "x=")
    sensor_y = parse_raw_number(raw_sensor_y, "y=")
    beacon_x = parse_raw_number(raw_beacon_x, "x=")
    beacon_y = parse_raw_number(raw_beacon_y, "y=")
    distance = take_a_taxi({sensor_x, sensor_y}, {beacon_x, beacon_y})
    {{sensor_x, sensor_y}, {beacon_x, beacon_y}, distance}
  end

  @spec parse_raw_number(String.t(), String.t()) :: integer()
  def parse_raw_number(raw_number, prefix) do
    raw_number
    |> String.split(prefix, trim: true)
    |> List.last()
    |> String.to_integer()
  end
end
