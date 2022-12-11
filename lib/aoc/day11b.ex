defmodule AOC.Day11b do
  use AOC

  @moduledoc """
  Does not currently work. Likely needs more stupid math tricks.
  """

  defmodule Monkey do
    use GenServer
    defstruct [:id, :items, :operation, :test, :n, :pass, :fail, :inspections]

    @type t :: %__MODULE__{
            id: integer(),
            items: [AOC.Day11b.item()],
            operation: AOC.Day11b.operation(),
            test: AOC.Day11b.test(),
            n: magic_number(),
            pass: integer(),
            fail: integer(),
            inspections: integer()
          }
    @type magic_number :: integer() | nil
    @type inspect_items_command :: :inspect_items
    @type inspect_items_response :: {:reply, :ok, t()}
    @type spy_command :: :spy
    @type spy_response :: {:reply, t(), t()}
    @type toss_item_command :: {:toss_item, AOC.Day11b.item()}
    @type toss_item_response :: {:reply, t(), t()}

    @spec start_link(t()) :: GenServer.on_start()
    def start_link(%{id: id} = monkey) do
      monkey = Map.put(monkey, :n, calculate_n(monkey.test))
      GenServer.start_link(__MODULE__, monkey, name: String.to_atom("monkey_#{id}"))
    end

    @spec init(t()) :: {:ok, t()}
    def init(monkey), do: {:ok, monkey}

    @spec inspect_items(t()) :: t()
    def inspect_items(monkey) do
      GenServer.call(String.to_atom("monkey_#{monkey.id}"), :inspect_items, 30_000)
    end

    @spec toss_item(integer(), AOC.Day11b.item()) :: :ok
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

    def handle_call({:spy}, _from, monkey) do
      {:reply, monkey, monkey}
    end

    @spec inspect_item(t(), AOC.Day11b.item()) :: :ok
    def inspect_item(monkey, item) do
      item = apply_operation(item, monkey.operation)

      if test_worry_level(item, monkey.test, monkey.n) do
        toss_item(monkey.pass, item)
      else
        toss_item(monkey.fail, item)
      end
    end

    @spec apply_operation(AOC.Day11b.item(), AOC.Day11b.operation()) :: AOC.Day11b.item()
    def apply_operation(item, {:old, :old, :+}), do: item + item
    def apply_operation(item, {:old, :old, :*}), do: item * item
    def apply_operation(item, {:old, worry_level, :+}), do: item + worry_level
    def apply_operation(item, {:old, worry_level, :*}), do: item * worry_level

    @spec test_worry_level(AOC.Day11b.item(), AOC.Day11b.test(), magic_number()) :: boolean()
    def test_worry_level(item, test, nil) do
      item
      |> Integer.to_string()
      |> String.last()
      |> String.to_integer()
      |> rem(test)
      |> Kernel.==(0)
    end

    def test_worry_level(item, test, _n) when item < test * 10 do
      rem(item, test) == 0
    end

    def test_worry_level(item, test, n) do
      [front, last] =
        item
        |> Integer.to_string()
        |> String.split_at(-1)
        |> Tuple.to_list()
        |> Enum.map(&String.to_integer/1)

      if n < test - n do
        test_worry_level(front + last * n, test, n)
      else
        test_worry_level(front - last * (test - n), test, n)
      end
    end

    @spec calculate_n(AOC.Day11b.test()) :: magic_number()
    def calculate_n(2), do: nil
    def calculate_n(5), do: nil
    def calculate_n(test), do: calculate_n(test, 2)

    @spec calculate_n(integer(), integer()) :: magic_number()
    def calculate_n(test, k) do
      if rem(test * k + 1, 10) == 0 do
        n = div(test * k + 1, 10)
        min(n, test - n)
      else
        calculate_n(test, k + 1)
      end
    end
  end

  @type item :: integer()
  @type monkey_business :: integer()
  @type operation :: {worry_level(), worry_level(), operator()}
  @type operator :: :+ | :*
  @type raw_input :: String.t()
  @type test :: integer()
  @type worry_level :: integer() | :old

  @spec solution(path()) :: monkey_business()
  def solution(path) do
    path
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_monkey/1)
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
      |> engage_in_monkey_business(rounds - 1)
    end)

    Enum.map(monkeys, &Monkey.stop/1)
  end

  @spec parse_monkey(raw_input()) :: Monkey.t()
  def parse_monkey(raw_input) do
    [monkey_identifier, starting_items, operation, test, pass, fail] =
      String.split(raw_input, "\n", trim: true)

    %Monkey{
      id: parse_monkey_identifier(monkey_identifier),
      items: parse_items(starting_items),
      operation: parse_operation(operation),
      test: parse_test(test),
      pass: parse_pass(pass),
      fail: parse_fail(fail),
      inspections: 0
    }
  end

  @spec parse_fail(raw_input()) :: integer()
  def parse_fail(pass) do
    pass
    |> String.split("monkey ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @spec parse_pass(raw_input()) :: integer()
  def parse_pass(pass) do
    pass
    |> String.split("monkey ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @spec parse_test(raw_input()) :: test()
  def parse_test(test) do
    test
    |> String.split("by ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @spec parse_operation(raw_input()) :: operation()
  def parse_operation(operation) do
    [w1, op, w2] =
      operation
      |> String.split("= ", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)

    {parse_worry_level(w1), parse_worry_level(w2), parse_operator(op)}
  end

  @spec parse_operator(raw_input()) :: operator()
  def parse_operator("+"), do: :+
  def parse_operator("*"), do: :*

  @spec parse_worry_level(raw_input()) :: worry_level()
  def parse_worry_level("old"), do: :old
  def parse_worry_level(worry_level), do: String.to_integer(worry_level)

  @spec parse_items(raw_input()) :: list(item())
  def parse_items(starting_items) do
    starting_items
    |> String.split(": ", trim: true)
    |> List.last()
    |> String.split(", ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @spec parse_monkey_identifier(raw_input()) :: integer()
  def parse_monkey_identifier(monkey_identifier) do
    monkey_identifier
    |> String.split(" ", trim: true)
    |> List.last()
    |> String.replace(":", "")
    |> String.to_integer()
  end
end
