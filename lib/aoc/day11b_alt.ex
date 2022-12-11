defmodule AOC.Day11b_alt do
  use AOC

  @moduledoc """
  I saw @ancallan@genserver.social solved this and I went to look at his code.
  You can see his code here: https://github.com/arlen-brower/aoc-2022/blob/main/11%20--%20Monkey%20Business/day_eleven.ex
  I spent some time working out in my head why that math works and once I got it
  I decided it was fair enough to implement it.
  I don't like implementing things unless I understand them, but after talking it out
  with myself I understood why it was legal to take the remainder from the lcm since
  it will only change it when the item is divisible by all the divisors which means
  the monkies will each have their checks still valid.
  I also liked a lot of his naming better so I changed up my naming.
  I'm not turning the the result from this, but if my takes forever version finishes
  I'll turn it in.
  """

  @type raw_input :: String.t()

  defmodule Monkey do
    use GenServer
    defstruct [:id, :items, :operation, :divisor, :lcm, :pass, :fail, :inspections]

    @type t :: %__MODULE__{
            id: monkey_id(),
            items: list(item()),
            operation: operation(),
            divisor: divisor(),
            lcm: magic_number(),
            pass: monkey_id(),
            fail: monkey_id(),
            inspections: monkey_business()
          }
    @type divisor :: integer()
    @type inspect_items_command :: :inspect_items
    @type inspect_items_response :: {:reply, :ok, t()}
    @type item :: integer()
    @type magic_number :: integer()
    @type monkey_id :: integer()
    @type monkey_business :: integer()
    @type operation :: {worry_level(), worry_level(), operator()}
    @type operator :: :+ | :*
    @type spy_command :: :spy
    @type spy_response :: {:reply, t(), t()}
    @type toss_item_command :: {:toss_item, AOC.Day11b.item()}
    @type toss_item_response :: {:reply, t(), t()}
    @type worry_level :: integer() | :old

    @spec start_link(t()) :: GenServer.on_start()
    def start_link(%{id: id} = monkey) do
      GenServer.start_link(__MODULE__, monkey, name: String.to_atom("monkey_#{id}"))
    end

    @spec init(t()) :: {:ok, t()}
    def init(monkey), do: {:ok, monkey}

    @spec inspect_items(t()) :: t()
    def inspect_items(monkey) do
      GenServer.call(String.to_atom("monkey_#{monkey.id}"), :inspect_items)
    end

    @spec toss_item(integer(), item()) :: :ok
    def toss_item(monkey_id, item) do
      GenServer.call(String.to_atom("monkey_#{monkey_id}"), {:toss_item, item})
    end

    @spec spy(t()) :: t()
    def spy(monkey) do
      GenServer.call(String.to_atom("monkey_#{monkey.id}"), :spy)
    end

    @spec stop(t()) :: t()
    def stop(monkey) do
      monkey = spy(monkey)
      GenServer.stop(String.to_atom("monkey_#{monkey.id}"))
      monkey
    end

    @spec calculate_lcm(list(t())) :: list(t())
    def calculate_lcm(monkeys) do
      lcm =
        monkeys
        |> Enum.map(& &1.divisor)
        |> Enum.product()

      Enum.map(monkeys, &Map.put(&1, :lcm, lcm))
    end

    @spec handle_call(
            inspect_items_command() | toss_item_command() | spy_command(),
            any(),
            t()
          ) ::
            inspect_items_response() | toss_item_response() | spy_response()
    def handle_call(:inspect_items, _from, monkey) do
      Enum.each(monkey.items, &inspect_item(monkey, &1))

      monkey =
        Map.merge(monkey, %{items: [], inspections: monkey.inspections + length(monkey.items)})

      {:reply, monkey, monkey}
    end

    def handle_call({:toss_item, item}, _from, monkey) do
      items = [item | Enum.reverse(monkey.items)] |> Enum.reverse()
      {:reply, :ok, Map.put(monkey, :items, items)}
    end

    def handle_call(:spy, _from, monkey) do
      {:reply, monkey, monkey}
    end

    @spec inspect_item(t(), item()) :: :ok
    def inspect_item(monkey, item) do
      item =
        item
        |> worry(monkey.operation)
        |> relieve(monkey.lcm)

      if test_worry_level(item, monkey.divisor) do
        toss_item(monkey.pass, item)
      else
        toss_item(monkey.fail, item)
      end
    end

    @spec worry(item(), operation()) :: item()
    def worry(item, {:old, :old, :+}), do: item + item
    def worry(item, {:old, :old, :*}), do: item * item
    def worry(item, {:old, worry_level, :+}), do: item + worry_level
    def worry(item, {:old, worry_level, :*}), do: item * worry_level

    @spec relieve(item(), magic_number()) :: item()
    def relieve(item, lcm), do: rem(item, lcm)

    @spec test_worry_level(item(), divisor()) :: boolean()
    def test_worry_level(item, divisor), do: rem(item, divisor) == 0
  end

  @spec solution(path()) :: Monkey.monkey_business()
  def solution(path) do
    path
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_monkey/1)
    |> Monkey.calculate_lcm()
    |> Enum.map(&start_monkey/1)
    |> engage_in_monkey_business(10_000)
    |> Enum.sort_by(& &1.inspections, :desc)
    |> Enum.take(2)
    |> Enum.map(& &1.inspections)
    |> Enum.product()
  end

  @spec start_monkey(Monkey.t()) :: Monkey.t()
  def start_monkey(monkey) do
    Monkey.start_link(monkey)
    monkey
  end

  @spec engage_in_monkey_business(list(Monkey.t()), integer()) :: list(Monkey.t())
  def engage_in_monkey_business(monkeys, rounds) do
    Enum.each(1..rounds, fn _ ->
      monkeys
      |> Enum.map(&Monkey.inspect_items/1)
    end)

    Enum.map(monkeys, &Monkey.stop/1)
  end

  @spec parse_monkey(raw_input()) :: Monkey.t()
  def parse_monkey(raw_input) do
    [monkey_id, starting_items, operation, divisor, pass, fail] =
      String.split(raw_input, "\n", trim: true)

    %Monkey{
      id: parse_monkey_id(monkey_id),
      items: parse_items(starting_items),
      operation: parse_operation(operation),
      divisor: parse_divisor(divisor),
      lcm: 1,
      pass: parse_pass(pass),
      fail: parse_fail(fail),
      inspections: 0
    }
  end

  @spec parse_fail(raw_input()) :: Monkey.monkey_id()
  def parse_fail(pass) do
    pass
    |> String.split("monkey ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @spec parse_pass(raw_input()) :: Monkey.monkey_id()
  def parse_pass(pass) do
    pass
    |> String.split("monkey ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @spec parse_divisor(raw_input()) :: Monkey.divisor()
  def parse_divisor(test) do
    test
    |> String.split("by ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @spec parse_operation(raw_input()) :: Monkey.operation()
  def parse_operation(operation) do
    [w1, op, w2] =
      operation
      |> String.split("= ", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)

    {parse_worry_level(w1), parse_worry_level(w2), parse_operator(op)}
  end

  @spec parse_operator(raw_input()) :: Monkey.operator()
  def parse_operator("+"), do: :+
  def parse_operator("*"), do: :*

  @spec parse_worry_level(raw_input()) :: Monkey.worry_level()
  def parse_worry_level("old"), do: :old
  def parse_worry_level(worry_level), do: String.to_integer(worry_level)

  @spec parse_items(raw_input()) :: list(Monkey.item())
  def parse_items(starting_items) do
    starting_items
    |> String.split(": ", trim: true)
    |> List.last()
    |> String.split(", ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec parse_monkey_id(raw_input()) :: Monkey.monkey_id()
  def parse_monkey_id(monkey_identifier) do
    monkey_identifier
    |> String.split(" ", trim: true)
    |> List.last()
    |> String.replace(":", "")
    |> String.to_integer()
  end
end
