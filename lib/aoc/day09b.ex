defmodule AOC.Day09b do
  use AOC
  use Vivid
  alias Vivid.PNG

  @type direction :: :U | :D | :L | :R
  @type flag :: boolean()
  @type head :: knot()
  @type knot :: {integer(), integer()}
  @type motion :: {direction(), step_count()}
  @type raw_input :: String.t()
  @type rope :: list(knot())
  @type step_count :: integer()
  @type tail :: knot()
  @type trail :: list(knot())

  @spec solution(path(), flag()) :: integer()
  def solution(filename, capture \\ false) do
    filename
    |> read_lines()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_motion/1)
    |> Enum.reduce({initialize_rope(), [], capture}, &move/2)
    |> elem(1)
    |> Enum.uniq()
    |> capture_trail(capture)
    |> Enum.count()
  end

  @spec move(motion(), {rope(), trail(), flag()}) :: {rope(), trail(), flag()}
  def move({_, 0}, {rope, trail, flag}), do: {rope, trail, flag}

  def move({:D, step_count}, {[{x, y} | knots], trail, flag}) do
    head = {x, y - 1}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:D, step_count - 1}, capture({[head | knots], [tail | trail], flag}))
  end

  def move({:U, step_count}, {[{x, y} | knots], trail, flag}) do
    head = {x, y + 1}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:U, step_count - 1}, capture({[head | knots], [tail | trail], flag}))
  end

  def move({:L, step_count}, {[{x, y} | knots], trail, flag}) do
    head = {x - 1, y}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:L, step_count - 1}, capture({[head | knots], [tail | trail], flag}))
  end

  def move({:R, step_count}, {[{x, y} | knots], trail, flag}) do
    head = {x + 1, y}
    [tail | _] = knots = pull_knots(knots, head)
    knots = Enum.reverse(knots)
    move({:R, step_count - 1}, capture({[head | knots], [tail | trail], flag}))
  end

  @spec pull_knots(list(knot()), head(), list(knot())) :: list(knot())
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

  def pull_tail({tx, ty}, {hx, hy}) when abs(hx - tx) == 2 and abs(hy - ty) == 2,
    do: {tx + div(hx - tx, 2), ty + div(hy - ty, 2)}

  def pull_tail({tx, ty}, {hx, hy}) when abs(hx - tx) == 2,
    do: {tx + div(hx - tx, 2), ty + (hy - ty)}

  def pull_tail({tx, ty}, {hx, hy}) when abs(hy - ty) == 2,
    do: {tx + (hx - tx), ty + div(hy - ty, 2)}

  def pull_tail({tx, ty}, {hx, _hy}) when abs(hx - tx) == 1, do: {tx, ty}

  @spec initialize_rope() :: rope()
  def initialize_rope(),
    do: Enum.map(1..10, fn _ -> {0, 0} end)

  @spec parse_motion(raw_input()) :: motion()
  def parse_motion(motion) do
    [direction, step_count] = String.split(motion, " ", parts: 2)
    {String.to_atom(direction), String.to_integer(step_count)}
  end

  @spec capture_trail(trail(), flag()) :: trail()
  def capture_trail(trail, false), do: trail

  def capture_trail(trail, true) do
    name = "images/trail.png"
    frame = Frame.init(250, 250, RGBA.white())

    path =
      trail
      |> Enum.map(fn {x, y} ->
        Point.init(x, y)
      end)
      |> Path.init()
      |> Transform.center(Bounds.init(0, 0, 250, 250))
      |> Transform.apply()

    Frame.push(frame, path, RGBA.black()) |> PNG.to_png(name)
    trail
  end

  @spec capture({rope(), trail(), flag()}) :: {rope(), trail(), flag()}
  def capture({rope, trail, false}), do: {rope, trail, false}

  def capture({rope, trail, true} = result) do
    name = "images/#{pad(length(trail))}.png"
    frame = Frame.init(100, 100, RGBA.white())

    rope =
      rope
      |> Enum.map(fn {x, y} ->
        Box.init(Point.init(x * 5 - 2, y * 5 - 2), Point.init(x * 5 + 2, y * 5 + 2))
      end)
      |> Group.init()
      |> Transform.center(Bounds.init(0, 0, 100, 100))
      |> Transform.apply()

    Frame.push(frame, rope, RGBA.black()) |> PNG.to_png(name)

    result
  end

  @spec pad(integer()) :: String.t()
  def pad(n) do
    String.pad_leading(Integer.to_string(n), 8, "0")
  end
end
