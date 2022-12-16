defmodule AOC.Day15a do
  use AOC

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
    |> determine_coverage(2_000_000)
  end

  @spec determine_coverage(list(reading()), integer()) :: integer()
  def determine_coverage(readings, y) do
    minx =
      readings
      |> Enum.map(fn {{x, _}, _, distance} -> x - distance end)
      |> Enum.min()

    maxx =
      readings
      |> Enum.map(fn {{x, _}, _, distance} -> x + distance end)
      |> Enum.max()

    total_coverage =
      minx..maxx
      |> Enum.reduce(0, fn x, coverage ->
        if covered?(readings, {x, y}), do: coverage + 1, else: coverage
      end)

    sensors = Enum.count(readings, fn {{_, sy}, _, _} -> sy == y end)

    beacons =
      readings
      |> Enum.uniq_by(fn {_, beacon, _} -> beacon end)
      |> Enum.count(fn {_, {_, by}, _} -> by == y end)

    total_coverage - beacons - sensors
  end

  @spec covered?(list(reading()), point()) :: boolean()
  def covered?(readings, point) do
    Enum.any?(readings, fn {sensor, _, distance} -> take_a_taxi(sensor, point) <= distance end)
  end

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
