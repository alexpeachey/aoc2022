defmodule AOC.Day12.AstralPlane do
  use GenServer

  @start_elevation "S"
  @end_elevation "E"
  @heights "abcdefghijklmnopqrstuvwxyz"
           |> String.split("", trim: true)
           |> Enum.with_index(1)
           |> Map.new()
           |> Map.put(@start_elevation, 1)
           |> Map.put(@end_elevation, 26)

  @type t :: list(list(astral_signature()))
  @type astral_projection :: {location(), steps()}
  @type astral_signature :: boolean()
  @type elevation :: String.t()
  @type elevation_map :: list(list(elevation()))
  @type host :: pid()
  @type location :: {integer(), integer()}
  @type state :: %{
          astral_plane: t(),
          host: host(),
          map: elevation_map(),
          projections: list(astral_projection())
        }
  @type steps :: integer()

  @spec in_bounds(integer(), integer(), elevation_map()) :: Macro.t()
  defguard in_bounds(x, y, map)
           when x >= 0 and y >= 0 and y < length(map) and x < length(hd(map))

  @spec out_of_bounds(integer(), integer(), elevation_map()) :: Macro.t()
  defguard out_of_bounds(x, y, map) when not in_bounds(x, y, map)

  @spec embark(host(), elevation_map(), location()) :: GenServer.on_start()
  def embark(host, map, location) do
    GenServer.start_link(__MODULE__, %{
      astral_plane: Enum.map(map, fn row -> Enum.map(row, fn _ -> false end) end),
      host: host,
      map: map,
      projections: [{location, 0}]
    })
  end

  @spec init(map()) :: {:ok, state(), {:continue, :astral_walk}}
  def init(state), do: {:ok, state, {:continue, :astral_walk}}

  @spec handle_continue(:astral_walk, state()) :: {:noreply, state()}
  def handle_continue(:astral_walk, state) do
    send(self(), :astral_walk)
    {:noreply, state}
  end

  @spec handle_info(:astral_walk, state()) :: {:noreply, state()}
  def handle_info(:astral_walk, %{host: host, projections: []} = state) do
    send(host, {:astral_walk_complete, self(), :infinity})
    {:stop, :normal, %{state | projections: []}}
  end

  def handle_info(
        :astral_walk,
        %{
          astral_plane: plane,
          host: host,
          map: map,
          projections: [{location, steps} = current | projections]
        } = state
      ) do
    if astral_presense?(location, plane) do
      send(self(), :astral_walk)
      {:noreply, %{state | projections: projections}}
    else
      case determine_elevation(location, map) do
        @end_elevation ->
          send(host, {:astral_walk_complete, self(), steps})
          {:stop, :normal, %{state | projections: []}}

        elevation ->
          new_projections = project_self(current, plane, map, elevation)
          send(self(), :astral_walk)

          {:noreply,
           %{
             state
             | astral_plane: trace(plane, location),
               projections: projections ++ new_projections
           }}
      end
    end
  end

  @spec project_self(astral_projection(), t(), elevation_map(), elevation()) ::
          list(astral_projection())
  def project_self({location, steps}, plane, map, elevation) do
    location
    |> adjacent_locations()
    |> Enum.reject(&astral_presense?(&1, plane))
    |> Enum.filter(&able_to_climb?(&1, elevation, map))
    |> Enum.map(fn location -> {location, steps + 1} end)
  end

  @spec able_to_climb?(location(), elevation(), elevation_map()) :: boolean()
  def able_to_climb?({x, y}, _elevation, map) when out_of_bounds(x, y, map), do: false

  def able_to_climb?(location, elevation, map) do
    destination = determine_elevation(location, map)
    # slope = @heights[destination] - @heights[elevation]
    # slope == 1 or slope == 0
    @heights[destination] - @heights[elevation] <= 1
  end

  @spec adjacent_locations(location()) :: list(location())
  def adjacent_locations({x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
  end

  @spec trace(t(), location()) :: t()
  def trace(plane, {x, y}) do
    List.replace_at(plane, y, List.replace_at(Enum.at(plane, y), x, true))
  end

  @spec astral_presense?(location(), t()) :: boolean()
  def astral_presense?({x, y}, plane) when in_bounds(x, y, plane) do
    Enum.at(Enum.at(plane, y), x)
  end

  def astral_presense?(_, _), do: false

  @spec determine_elevation(location(), elevation_map()) :: elevation()
  def determine_elevation({x, y}, map), do: Enum.at(Enum.at(map, y), x)

  @spec start_elevation() :: elevation()
  def start_elevation(), do: @start_elevation
  @spec end_elevation() :: elevation()
  def end_elevation(), do: @end_elevation
end
