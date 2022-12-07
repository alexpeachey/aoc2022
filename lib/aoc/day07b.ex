defmodule AOC.Day07b do
  use AOC

  @disk_space 70_000_000
  @update_size 30_000_000

  @type directory :: String.t()
  @type disk_usage :: integer()
  @type file :: String.t()
  @type file_path :: list(String.t())
  @type file_size :: integer()
  @type filesystem :: %{directory() => filesystem(), file() => file_size()}
  @type raw_input :: list(String.t())
  @type usage_summary :: %{file_path() => disk_usage()}

  @spec solution(path()) :: disk_usage()
  def solution(path) do
    summary =
      path
      |> read_lines()
      |> Enum.map(&String.trim/1)
      |> build_filesystem()
      |> summarize()

    needed = @update_size - (@disk_space - summary[["/"]])

    summary
    |> find_candidates(needed)
    |> Enum.min_by(fn {_path, disk_usage} -> disk_usage end)
    |> elem(1)
  end

  @spec find_candidates(usage_summary(), disk_usage()) :: usage_summary()
  def find_candidates(usage_summary, needed) do
    usage_summary
    |> Enum.filter(fn {_path, disk_usage} -> disk_usage >= needed end)
    |> Map.new()
  end

  @spec summarize(
          filesystem() | {directory(), filesystem()} | {file(), file_size()},
          usage_summary(),
          file_path()
        ) :: usage_summary()
  def summarize(filesystem, usage_summary \\ %{}, path \\ [])

  def summarize(%{"/" => filesystem}, usage_summary, []) do
    size =
      filesystem
      |> Map.values()
      |> Enum.reduce(0, &calculate_size/2)

    Enum.reduce(filesystem, Map.put(usage_summary, ["/"], size), &summarize(&1, &2, ["/"]))
  end

  def summarize({directory, filesystem}, usage_summary, path) when is_map(filesystem) do
    size =
      filesystem
      |> Map.values()
      |> Enum.reduce(0, &calculate_size/2)

    Enum.reduce(
      filesystem,
      Map.put(usage_summary, [directory | path], size),
      &summarize(&1, &2, [directory | path])
    )
  end

  def summarize({_file, file_size}, usage_summary, _path) when is_integer(file_size),
    do: usage_summary

  @spec calculate_size(filesystem() | file_size(), integer()) :: integer()
  def calculate_size(filesystem, size) when is_map(filesystem) do
    filesystem
    |> Map.values()
    |> Enum.reduce(size, &calculate_size/2)
  end

  def calculate_size(file_size, size) when is_integer(file_size) do
    size + file_size
  end

  @spec build_filesystem(raw_input(), filesystem(), file_path()) :: filesystem()
  def build_filesystem(raw_input, filesystem \\ %{}, path \\ [])

  def build_filesystem([], filesystem, _path), do: filesystem

  def build_filesystem(["$ cd .." | rest], filesystem, path),
    do: build_filesystem(rest, filesystem, tl(path))

  def build_filesystem(["$ cd /" | rest], filesystem, _path),
    do: build_filesystem(rest, Map.put_new(filesystem, "/", %{}), ["/"])

  def build_filesystem(["$ cd " <> directory | rest], filesystem, path),
    do:
      build_filesystem(
        rest,
        put_in(
          filesystem,
          Enum.reverse(path),
          Map.put_new(get_in(filesystem, Enum.reverse(path)), directory, %{})
        ),
        [directory | path]
      )

  def build_filesystem(["$ ls" | rest], filesystem, path),
    do: build_filesystem(rest, filesystem, path)

  def build_filesystem(["dir " <> _directory | rest], filesystem, path),
    do: build_filesystem(rest, filesystem, path)

  def build_filesystem([entry | rest], filesystem, path) do
    [file_size, filename] = String.split(entry, " ")
    file_size = String.to_integer(file_size)
    filesystem = put_in(filesystem, Enum.reverse([filename | path]), file_size)
    build_filesystem(rest, filesystem, path)
  end
end
