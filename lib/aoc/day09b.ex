defmodule AOC.Day09b do
  use AOC

  @type direction() :: :U | :D | :L | :R
  @type head() :: knot_location()
  @type knot_location() :: {integer(), integer()}
  @type motion() :: {direction(), step_count()}
  @type raw_input() :: String.t()
  @type rope() :: {[tail()], head()}
  @type step_count() :: integer()
  @type tail() :: knot_location()
  @type trail() :: [knot_location()]

  @spec solution(path()) :: integer()
  def solution(filename) do
    filename
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_motion/1)
    |> Enum.reduce({initialize_rope(), [{0, 0}]}, &move/2)
    |> elem(1)
    |> Enum.uniq()
    |> Enum.count()
  end

  @spec move(motion(), {rope(), trail()}) :: {rope(), trail()}
  def move({_, 0}, {rope, trail}), do: {rope, trail}

  def move({:D, step_count}, {{knots, {x, y}}, trail}) do
    head = {x, y - 1}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:D, step_count - 1}, {{knots, head}, [tail | trail]})
  end

  def move({:U, step_count}, {{knots, {x, y}}, trail}) do
    head = {x, y + 1}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:U, step_count - 1}, {{knots, head}, [tail | trail]})
  end

  def move({:L, step_count}, {{knots, {x, y}}, trail}) do
    head = {x - 1, y}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:L, step_count - 1}, {{knots, head}, [tail | trail]})
  end

  def move({:R, step_count}, {{knots, {x, y}}, trail}) do
    head = {x + 1, y}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:R, step_count - 1}, {{knots, head}, [tail | trail]})
  end

  @spec pull_knots(list(tail()), head(), list(tail())) :: list(tail())
  def pull_knots(knots, head, moved_knots \\ [])
  def pull_knots([], _, moved_knots), do: moved_knots

  def pull_knots([tail | knots], head, moved_knots) do
    tail = pull_tail(tail, head)
    pull_knots(knots, tail, [tail | moved_knots])
  end

  @spec pull_tail(tail(), head()) :: tail()
  def pull_tail({x, y}, {x, y}), do: {x, y}
  def pull_tail({x, ty}, {x, hy}), do: {x, ty + div(hy - ty, 2)}
  def pull_tail({tx, y}, {hx, y}), do: {tx + div(hx - tx, 2), y}

  def pull_tail({tx, ty}, {hx, hy}) when abs(hx - tx) == 2,
    do: {tx + div(hx - tx, 2), ty + (hy - ty)}

  def pull_tail({tx, ty}, {hx, hy}) when abs(hy - ty) == 2,
    do: {tx + (hx - tx), ty + div(hy - ty, 2)}

  def pull_tail({tx, ty}, {hx, _hy}) when abs(hx - tx) == 1, do: {tx, ty}

  @spec initialize_rope() :: rope()
  def initialize_rope(),
    do: {[{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}], {0, 0}}

  @spec parse_motion(raw_input()) :: motion()
  def parse_motion(motion) do
    [direction, step_count] = String.split(motion, " ", parts: 2)
    {String.to_atom(direction), String.to_integer(step_count)}
  end
end
