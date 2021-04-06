defmodule P3 do
  @moduledoc """
    ## Examples

    iex> P3.solve(5)
    4

    iex> P3.solve(11)
    9

    iex> P3.solve(4)
    -1

  """
  def main do
    IO.read(:line) |> String.trim() |> String.to_integer() |> solve() |> IO.puts()
  end

  defmodule Heap do
    defstruct data: nil, comparator: nil
  
    def new(comparator), do: %__MODULE__{comparator: comparator}
  
    def empty?(%__MODULE__{data: nil}), do: true
    def empty?(%__MODULE__{}), do: false 
  
    def size(%__MODULE__{data: nil}), do: 0
    def size(%__MODULE__{data: {size, _value, _left, _right}}), do: size

    def top(%__MODULE__{data: nil}), do: nil
    def top(%__MODULE__{data: {_size, value, _left, _right}}), do: value
  
    def pop(%__MODULE__{data: data, comparator: comp} = heap) do
      %{ heap | data: do_pop(comp, data)}
    end
  
    defp do_pop(_comparator, nil), do: nil
    defp do_pop(comparator, {size, _v0, left, right}) do
      with nil <- swap_on_pop(comparator, left, right) do
        nil
      else
        {v1, left, right} ->
          {size - 1, v1, do_pop(comparator, left), right}
      end
    end
  
    defp swap_on_pop(comparator, left, right)
    defp swap_on_pop(_comparator, nil, nil),   do: nil
    defp swap_on_pop(_comparator, left, nil),  do: {elem(left, 1), left, nil}
    defp swap_on_pop(_comparator, nil, right), do: {elem(right, 1), right, nil}
    defp swap_on_pop(comparator, left, right),
      do: if comparator.(elem(left, 1), elem(right, 1)),
        do:   {elem(left, 1), left, right},
        else: {elem(right,1), right, left}

    def push(%__MODULE__{data: data, comparator: comp} = heap, value) do
      %{
        heap |
        data: do_push(value, comp, data)
      }
    end
  
    defp do_push(value, comparator, data \\ nil)
    defp do_push(v0, _comparator, nil), do: {1, v0, nil, nil}
    defp do_push(v0, comparator, {size, v1, nil, nil}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      {size + 1, v0, do_push(v1, comparator), nil}
    end
    defp do_push(v0, comparator, {size, v1, left, nil}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      {size + 1, v0, left, do_push(v1, comparator)}
    end
    defp do_push(v0, comparator, {size, v1, nil, right}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      {size + 1, v0, do_push(v1, comparator), right}
    end
    defp do_push(v0, comparator, {size, v1, {ls, _, _, _} = left, {rs, _, _, _} = right}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      if rs < ls do
        {size + 1, v0, left, do_push(v1, comparator, right)}
      else
        {size + 1, v0, do_push(v1, comparator, left), right}
      end
    end
  
    defp swap_on_push(v0, v1, comparator) do
      if comparator.(v0, v1) do
        {v0, v1}
      else
        {v1, v0}
      end
    end

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
      def reduce(%Heap{data: nil}, {:cont, acc}, _fun), do: {:done, acc}
      def reduce(heap, {:cont, acc}, fun) do
        reduce(Heap.pop(heap), fun.(Heap.top(heap), acc), fun)
      end
    end
  end

  def solve(n) do
    {sets, seen} = greedy({1, 1}, n)

    sets
    |> Enum.into(
      Heap.new(
        fn {s0, p0}, {s1, p1} ->
          s0 < s1 || (s0 == s1 && p0 > p1)
        end
      )
    )
    |> do_solve(n, seen)
  end

  defp greedy(seed, n, seen \\ %{}) do
    fn {s0, p0}, {s1, p1} ->
      s0 > s1 || (s0 == s1 && p0 > p1)
    end
    |> Heap.new()
    |> Heap.push(seed) 
    |> do_greedy(n, seen)
  end

  defp do_greedy(heap, n, seen) do
    with set <- Heap.top(heap),
      [] <- next(set, n, seen) do
        {Enum.to_list(heap), seen}
    else
      arr when is_list(arr) ->
        {step, position} = Heap.top(heap)
        arr
        |> Enum.into(Heap.pop(heap))
        |> do_greedy(n, Map.put(seen, position, step))
    end
  end

  def do_solve(heap, n, seen \\ %{}) do
    with false <- Heap.empty?(heap),
      {step, position} when position == n <- Heap.top(heap) do
        step
    else
      true ->
        -1
      {step, position} = set ->
        with [seed] <- next(set, n, seen) do
          {sets, seen} = greedy(seed, n, Map.put(seen, position, step))
          sets
          |> Enum.into(Heap.pop(heap))
          |> do_solve(n, seen)
        else
          sets ->
            sets
            |> Enum.into(Heap.pop(heap))
            |> do_solve(n, Map.put(seen, position, step))
        end
    end
  end

  defp next({_s, p}, n, _seen) when n <= p, do: []
  defp next({s, p}, n, seen) do
    p
    |> to_displacement()
    |> (fn d ->
      [{s + 1, p - d}, {s + 1, p + d}]
      |> Enum.filter(fn 
        {step, position} when 1 < position and position <= n ->
          is_nil(seen[position]) || step < seen[position]
        _ ->
          false
      end)
    end).()
  end

  defp to_displacement(n), do: n |> Integer.digits(2) |> Enum.sum()
end

"""
defmodule Main do
  def main do
    IO.read(:line) |> String.trim() |> String.to_integer() |> solve() |> IO.puts()
  end

  defmodule Heap do
    defstruct data: nil, comparator: nil
  
    def new(comparator), do: %__MODULE__{comparator: comparator}
  
    def empty?(%__MODULE__{data: nil}), do: true
    def empty?(%__MODULE__{}), do: false

    def top(%__MODULE__{data: nil}), do: nil
    def top(%__MODULE__{data: {_size, value, _left, _right}}), do: value
  
    def pop(%__MODULE__{data: data, comparator: comp} = heap) do
      %{ heap | data: do_pop(comp, data)}
    end
  
    defp do_pop(_comparator, nil), do: nil
    defp do_pop(comparator, {size, _v0, left, right}) do
      with nil <- swap_on_pop(comparator, left, right) do
        nil
      else
        {v1, left, right} ->
          {size - 1, v1, do_pop(comparator, left), right}
      end
    end
  
    defp swap_on_pop(comparator, left, right)
    defp swap_on_pop(_comparator, nil, nil),   do: nil
    defp swap_on_pop(_comparator, left, nil),  do: {elem(left, 1), left, nil}
    defp swap_on_pop(_comparator, nil, right), do: {elem(right, 1), right, nil}
    defp swap_on_pop(comparator, left, right),
      do: if comparator.(elem(left, 1), elem(right, 1)),
        do:   {elem(left, 1), left, right},
        else: {elem(right,1), right, left}

    def push(%__MODULE__{data: data, comparator: comp} = heap, value) do
      %{heap | data: do_push(value, comp, data)}
    end
  
    defp do_push(value, comparator, data \\ nil)
    defp do_push(v0, _comparator, nil), do: {1, v0, nil, nil}
    defp do_push(v0, comparator, {size, v1, nil, nil}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      {size + 1, v0, do_push(v1, comparator), nil}
    end
    defp do_push(v0, comparator, {size, v1, left, nil}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      {size + 1, v0, left, do_push(v1, comparator)}
    end
    defp do_push(v0, comparator, {size, v1, nil, right}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      {size + 1, v0, do_push(v1, comparator), right}
    end
    defp do_push(v0, comparator, {size, v1, {ls, _, _, _} = left, {rs, _, _, _} = right}) do
      {v0, v1} = swap_on_push(v0, v1, comparator) 
      if rs < ls do
        {size + 1, v0, left, do_push(v1, comparator, right)}
      else
        {size + 1, v0, do_push(v1, comparator, left), right}
      end
    end
  
    defp swap_on_push(v0, v1, comparator) do
      if comparator.(v0, v1), do: {v0, v1}, else: {v1, v0}
    end

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
      def reduce(%Heap{data: nil}, {:cont, acc}, _fun), do: {:done, acc}
      def reduce(heap, {:cont, acc}, fun) do
        reduce(Heap.pop(heap), fun.(Heap.top(heap), acc), fun)
      end
    end
  end

  def solve(n) do
    {sets, seen} = greedy({1, 1}, n)

    sets
    |> Enum.into(
      Heap.new(
        fn {s0, p0}, {s1, p1} ->
          s0 < s1 || (s0 == s1 && p0 > p1)
        end
      )
    )
    |> do_solve(n, seen)
  end

  defp greedy(seed, n, seen \\ %{}) do
    fn {s0, p0}, {s1, p1} ->
      s0 > s1 || (s0 == s1 && p0 > p1)
    end
    |> Heap.new()
    |> Heap.push(seed) 
    |> do_greedy(n, seen)
  end

  defp do_greedy(heap, n, seen) do
    with set <- Heap.top(heap),
      [] <- next(set, n, seen) do
        {Enum.to_list(heap), seen}
    else
      arr when is_list(arr) ->
        {step, position} = Heap.top(heap)
        arr
        |> Enum.into(Heap.pop(heap))
        |> do_greedy(n, Map.put(seen, position, step))
    end
  end

  def do_solve(heap, n, seen \\ %{}) do
    with false <- Heap.empty?(heap),
      {step, position} when position == n <- Heap.top(heap) do
        step
    else
      true ->
        -1
      {step, position} = set ->
        with [seed] <- next(set, n, seen) do
          {sets, seen} = greedy(seed, n, Map.put(seen, position, step))
          sets
          |> Enum.into(Heap.pop(heap))
          |> do_solve(n, seen)
        else
          sets ->
            sets
            |> Enum.into(Heap.pop(heap))
            |> do_solve(n, Map.put(seen, position, step))
        end
    end
  end

  defp next({_s, p}, n, _seen) when n <= p, do: []
  defp next({s, p}, n, seen) do
    p
    |> to_displacement()
    |> (fn d ->
      [{s + 1, p - d}, {s + 1, p + d}]
      |> Enum.filter(fn 
        {step, position} when 1 < position and position <= n ->
          is_nil(seen[position]) || step < seen[position]
        _ ->
          false
      end)
    end).()
  end

  defp to_displacement(n), do: n |> Integer.digits(2) |> Enum.sum()
end
"""