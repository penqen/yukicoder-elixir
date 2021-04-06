defmodule P9 do
  @moduledoc """
  # Definition
  - レベルアップ = floor(倒したモンスターのレベル / 2)
  - 敵は円状に並んでいる
  - 最初の敵は選べる
  - 戦わせる順番は、一戦ごとに決め、min level and min fight

  - 手持ちのパーティー中で戦闘回数が一番多い回数がもっとも低くなるように、最初に戦う相手を選ぶ。
  - その際の、一番戦闘回数が多い数を求める。

  1_500 * 

  # Examples
    iex> P9.solve(3, [6, 1, 5], [9, 2, 7])
    2

    iex> P9.solve(5, [6, 1, 5, 9, 2], [7, 7, 9, 4, 4])
    2
  """
  use Bitwise

  defmodule Heap do
    defstruct data: nil, size: 0, comparator: nil
  
    def new(comparator), do: %__MODULE__{comparator: comparator}
    def empty?(%__MODULE__{data: nil, size: 0}), do: true
    def empty?(%__MODULE__{}), do: false 
    def size(%__MODULE__{size: size}), do: size
    def top(%__MODULE__{data: nil}), do: nil
    def top(%__MODULE__{data: {v, _}}), do: v
    def pop(%__MODULE__{data: nil, size: 0} = heap), do: heap
    def pop(%__MODULE__{data: {_v, queue}, size: n, comparator: comp} = heap),
      do: %{heap | data: dequeue(queue, comp), size: n - 1}
    def pop!(%__MODULE__{} = heap), do: {Heap.top(heap), Heap.pop(heap)}
    def push(%__MODULE__{data: h, size: n, comparator: comp} = heap, v),
      do: %{heap | data: meld(h, {v, nil}, comp), size: n + 1}
    defp meld(nil, v, _comp), do: v
    defp meld(v, nil, _comp), do: v
    defp meld({v0, q0} = left , {v1, q1} = right, comp) do
      if comp.(v0, v1) do
        {v0, enqueue(q0, right)}
      else
        {v1, enqueue(q1, left)}
      end
    end
  
    defp enqueue(q, v)
    defp enqueue(nil, v), do: [v]
    defp enqueue(q, v), do: [v | q]
  
    defp dequeue(nil, _), do: nil
    defp dequeue([], _), do: nil
    defp dequeue([q], _), do: q
    defp dequeue([q0, q1 | q], comp),
      do: meld(meld(q0, q1, comp), dequeue(q, comp), comp)
  
    defimpl Collectable do
      def into(heap) do
        {
          heap,
          fn
            heap, {:cont, v} -> Heap.push(heap, v)
            heap, :done -> heap
            _heap, :halt -> :ok
          end
        }
      end
    end
  
    defimpl Enumerable do
      def count(heap), do: {:ok, Heap.size(heap)}
      def member?(_, _), do: {:error, __MODULE__}
      def slice(_), do: {:error, __MODULE__}
      def reduce(_heap, {:halt, acc}, _fun), do: {:halted, acc}
      def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}
      def reduce(%Heap{data: nil, size: 0}, {:cont, acc}, _fun), do: {:done, acc}
      def reduce(heap, {:cont, acc}, fun) do
        reduce(Heap.pop(heap), fun.(Heap.top(heap), acc), fun)
      end
    end
  end

  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer();
    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    bn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    IO.puts solve(n, an, bn)
  end

  def solve(n, an, bn) do
    heap = fn {ll, lt}, {rl, rt} -> ll < rl || ll == rl && lt < rt end
    |> Heap.new()
    |> (&Enum.into(an, &1, fn lvl -> {lvl, 0} end)).()

    0..(n-1)
    |> Enum.reduce(:infinity, fn i, min ->
      times = non_recursion(heap, Enum.split(bn, i))
      if min < times, do: min, else: times
    end)
  end

  def solve_task(n, an, bn) do
    heap = fn {ll, lt}, {rl, rt} -> ll < rl || ll == rl && lt < rt end
    |> Heap.new()
    |> (&Enum.into(an, &1, fn lvl -> {lvl, 0} end)).()

    for i <- 0..(n-1) do
      Task.async(fn -> non_recursion(heap, Enum.split(bn, i)) end)
    end
    |> Enum.reduce(:infinity, fn task, min ->
      times = Task.await(task, 50_000)
      if min < times, do: min, else: times
    end)
  end

  def solve_spawn(n, an, bn) do
    heap = fn {ll, lt}, {rl, rt} -> ll < rl || ll == rl && lt < rt end
    |> Heap.new()
    |> (&Enum.into(an, &1, fn lvl -> {lvl, 0} end)).()

    current = self()
    for i <- 0..(n-1) do
      spawn_link(fn -> send(current, {self(), non_recursion(heap, Enum.split(bn, i))}) end)
    end
    |> Enum.reduce(:infinity, fn pid, min ->
      receive do
        {^pid, times} -> if min < times, do: min, else: times
      end
    end)
  end

  def solve_recursion(n, an, bn) do
    heap = fn {ll, lt}, {rl, rt} -> ll < rl || ll == rl && lt < rt end
    |> Heap.new()
    |> (&Enum.into(an, &1, fn lvl -> {lvl, 0} end)).()

    for i <- 0..(n-1) do
      {bn1, bn0} = Enum.split(bn, i)
      fight(heap, bn0, bn1)
    end
    |> Enum.min()
  end

  def solve_task_recursion(n, an, bn) do
    heap = fn {ll, lt}, {rl, rt} -> ll < rl || ll == rl && lt < rt end
    |> Heap.new()
    |> (&Enum.into(an, &1, fn lvl -> {lvl, 0} end)).()

    for i <- 0..(n-1) do
      {bn1, bn0} = Enum.split(bn, i)
      Task.async(fn -> fight(heap, bn0, bn1) end)
    end
    |> Enum.map(fn task -> Task.await(task, 50_000) end)
    |> Enum.min()
  end

  def solve_spawn_recursion(n, an, bn) do
    heap = fn {ll, lt}, {rl, rt} -> ll < rl || ll == rl && lt < rt end
    |> Heap.new()
    |> (&Enum.into(an, &1, fn lvl -> {lvl, 0} end)).()

    current = self()
    for i <- 0..(n-1) do
      {bn1, bn0} = Enum.split(bn, i)
      spawn_link(fn -> send(current, {self(), fight(heap, bn0, bn1)}) end)
    end
    |> Enum.map(fn pid ->
      receive do
        {^pid, times} -> times
      end
    end)
    |> Enum.min()
  end

  def non_recursion(heap, {bn1, bn0}) do
    [bn0, bn1]
    |> Enum.reduce(heap, fn list, heap ->
      Enum.reduce(list, heap, fn b, heap ->
        with {a, heap} <- Heap.pop!(heap) do
          Heap.push(heap, level_up(a, b))
        end
      end)
    end)
    |> Enum.max_by(fn {_lvl, time} -> time end)
    |> elem(1)
  end

  def fight(heap, bn, bn_next)
  def fight(heap, [], []), do: heap |> Enum.max_by(fn {_lvl, time} -> time end) |> elem(1)
  def fight(heap, [], bn), do: fight(heap, bn, [])
  def fight(heap, [b | tail], bn) do
    a = Heap.top(heap)
    heap |> Heap.pop() |> Heap.push(level_up(a, b)) |> fight(tail, bn)
  end

  def level_up({lvl, times}, b), do: {lvl + floor(b / 2), times + 1}

  def bfight(heap, bn0, bn1)
  def bfight(heap, [], []), do: heap |> Enum.max_by(fn v -> v &&& 0xFFF end) |> Bitwise.&&&(0xFFF)
  def bfight(heap, [], bn), do: bfight(heap, bn, [])
  def bfight(heap, [b | tail], bn) do
    {a, heap} = Heap.pop!(heap)
    heap |> Heap.push(a + b + 1) |> bfight(tail, bn)
  end

  def fight_queue(heap, bn)
  def fight_queue(heap, {[], []}), do: heap |> Enum.max_by(fn v -> v &&& 0xFFF end) |> Bitwise.&&&(0xFFF)
  def fight_queue(heap, {_, _} = q) do
    {a, heap} = Heap.pop!(heap)
    {{_, b}, q} = :queue.out(q)
    heap |> Heap.push(a + b + 1) |> fight_queue(q)
  end
  def fight_queue(heap, bn0, bn1)
  def fight_queue(heap, [], bn), do: fight_queue(heap, bn)
  def fight_queue(heap, [b | tail], bn) do
    {a, heap} = Heap.pop!(heap)
    heap |> Heap.push(a + b + 1) |> fight_queue(tail, bn)
  end

  def bsolve(n, an, bn) do
    heap = an |> Enum.map(&(&1 <<< 12)) |> Enum.into(Heap.new(fn l, r -> l < r end))
    bn = bn |> Enum.map(&(div(&1, 2) <<< 12))

    for i <- 0..(n-1) do
      {bn1, bn0} = Enum.split(bn, i)
      bfight(heap, bn0, bn1)
    end
    |> Enum.min()
  end 

  def bsolve_spawn(n, an, bn) do
    heap = an |> Enum.map(&(&1 <<< 12)) |> Enum.into(Heap.new(fn l, r -> l < r end))
    bn = bn |> Enum.map(&(div(&1, 2) <<< 12))

    current = self()
    for i <- 0..(n-1) do
      {bn1, bn0} = Enum.split(bn, i)
      spawn_link(fn -> send(current, {self(), bfight(heap, bn0, bn1)}) end)
    end
    |> Enum.reduce(:infinity, fn pid, min ->
      receive do
        {^pid, times} -> if min > times, do: times, else: min
      end
    end)
  end 

  def split([], q), do: {[], q}
  def split([h | t], q), do: {t, :queue.in(h, q)}

  def bsolve_spawn_split(n, an, bn) do
    heap = an |> Enum.map(&(&1 <<< 12)) |> Enum.into(Heap.new(fn l, r -> l < r end))
    bn = bn |> Enum.map(&(div(&1, 2) <<< 12))

    current = self()
    for i <- 0..(n-1) do
      spawn_link(fn ->
        {bn1, bn0} = Enum.split(bn, i)
        send(current, {self(), bfight(heap, bn0, bn1)})
      end)
    end
    |> Enum.reduce(:infinity, fn pid, min ->
      receive do
        {^pid, times} -> if min > times, do: times, else: min
      end
    end)
  end 

  def bsolve_spawn_queue(n, an, bn) do
    heap = an |> Enum.map(&(&1 <<< 12)) |> Enum.into(Heap.new(fn l, r -> l < r end))
    bn = bn |> Enum.map(&(div(&1, 2) <<< 12))

    current = self()

    1..n
    |> Enum.reduce({:queue.new, {bn, :queue.new}}, fn _, {pids, {bn, bn_rotate}} ->
      pid = spawn_link(fn ->
        send(current, {self(), fight_queue(heap, bn, bn_rotate)})
      end)
      {:queue.in(pid, pids), split(bn, bn_rotate)}
    end)
    |> (fn {q, _} -> :queue.to_list(q) end).()
    |> Enum.reduce(:infinity, fn pid, min ->
      receive do
        {^pid, times} -> if min > times, do: times, else: min
      end
    end)
  end 
end

"""
defmodule Main do
  use Bitwise
  defmodule Heap do
    defstruct data: nil, size: 0, comparator: nil
    def new(comparator), do: %__MODULE__{comparator: comparator}
    def empty?(%__MODULE__{data: nil, size: 0}), do: true
    def empty?(%__MODULE__{}), do: false 
    def size(%__MODULE__{size: size}), do: size
    def top(%__MODULE__{data: nil}), do: nil
    def top(%__MODULE__{data: {v, _}}), do: v
    def pop(%__MODULE__{data: nil, size: 0} = heap), do: heap
    def pop(%__MODULE__{data: {_v, queue}, size: n, comparator: comp} = heap),
      do: %{heap | data: dequeue(queue, comp), size: n - 1}
    def pop!(%__MODULE__{} = heap), do: {Heap.top(heap), Heap.pop(heap)}
    def push(%__MODULE__{data: h, size: n, comparator: comp} = heap, v),
      do: %{heap | data: meld(h, {v, nil}, comp), size: n + 1}
    defp meld(nil, v, _comp), do: v
    defp meld(v, nil, _comp), do: v
    defp meld({v0, q0} = left , {v1, q1} = right, comp) do
      if comp.(v0, v1), do: {v0, enqueue(q0, right)}, else: {v1, enqueue(q1, left)}
    end
    defp enqueue(q, v)
    defp enqueue(nil, v), do: [v]
    defp enqueue(q, v), do: [v | q]
    defp dequeue(nil, _), do: nil
    defp dequeue([], _), do: nil
    defp dequeue([q], _), do: q
    defp dequeue([q0, q1 | q], comp), do: meld(meld(q0, q1, comp), dequeue(q, comp), comp)
    defimpl Collectable do
      def into(heap) do
        {
          heap,
          fn
            heap, {:cont, v} -> Heap.push(heap, v)
            heap, :done -> heap
            _heap, :halt -> :ok
          end
        }
      end
    end
    defimpl Enumerable do
      def count(heap), do: {:ok, Heap.size(heap)}
      def member?(_, _), do: {:error, __MODULE__}
      def slice(_), do: {:error, __MODULE__}
      def reduce(_heap, {:halt, acc}, _fun), do: {:halted, acc}
      def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}
      def reduce(%Heap{data: nil, size: 0}, {:cont, acc}, _fun), do: {:done, acc}
      def reduce(heap, {:cont, acc}, fun) do
        reduce(Heap.pop(heap), fun.(Heap.top(heap), acc), fun)
      end
    end
  end

  def main do
    n = IO.read(:line)
    an = IO.read(:line)
    bn = IO.read(:line)
    current = self()
    n = spawn_link(fn -> send(current, {self(), n |> String.trim() |> String.to_integer()}) end)
    an = spawn_link(fn -> send(current, {self(), an |> String.trim() |> String.split(" ") |> Enum.map(&(String.to_integer(&1) <<< 12)) |> Enum.into(Heap.new(fn l, r -> l < r end)) }) end)
    bn = spawn_link(fn -> send(current, {self(), bn |> String.trim() |> String.split(" ") |> Enum.map(&(div(String.to_integer(&1), 2) <<< 12)) }) end) 
    n = receive do {^n, v} -> v end
    heap = receive do {^an, v} -> v end
    bn = receive do {^bn, v} -> v end
    for i <- 0..(n-1) do
      {bn1, bn0} = Enum.split(bn, i)
      fight(heap, bn0, bn1)
    end
    |> Enum.reduce(:infinity, fn times, min ->
      if min > times, do: times, else: min
    end)
    |> IO.puts
  end 

  def fight(heap, bn0, bn1)
  def fight(heap, [], []), do: heap |> Enum.max_by(fn v -> v &&& 0xFFF end) |> Bitwise.&&&(0xFFF)
  def fight(heap, [], bn), do: fight(heap, bn, [])
  def fight(heap, [b | tail], bn) do
    {a, heap} = Heap.pop!(heap)
    heap |> Heap.push(a + b + 1) |> fight(tail, bn)
  end
end
"""