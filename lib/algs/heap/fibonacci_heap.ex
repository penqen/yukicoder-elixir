defmodule FibonacciHeap do
  @moduledoc """
  参考 : https://www.cs.princeton.edu/~wayne/teaching/fibonacci-heap.pdf

  前提として、delete-minしか想定しないので、マークの設定はしない。
  (ポインタがないので、ランク計算は、非効率になりうる)
  また、ルートだけ一つに固定し、ルート以下の子供に対してフィボなビッチヒープを構成するようにする。

  data: {property, queue}
  queue: {property, queue}

  # Insert
  O(1)
  data: {property, queue}
  - min-propertyを満たす場合
    - propertyと交換しqueueへ突っ込む。
  - 満たさない場合、
    - そのままqueueへ突っ込む。

  # Delete-min
  O(log n)

  - ルートを取り出し、新しいルートを決める。
  - 必要に応じてマージする。


  """
  defstruct data: nil, size: 0, comparator: nil

  def new(comparator), do: %__MODULE__{comparator: comparator}

  def empty?(%__MODULE__{data: nil, size: 0}), do: true
  def empty?(%__MODULE__{}), do: false 

  def size(%__MODULE__{size: size}), do: size

  def top(%__MODULE__{data: nil}), do: nil
  def top(%__MODULE__{data: {v, _}}), do: v

  @doc """
  ## Examples

  iex> alias FibonacciHeap, as: Heap
  ...> Heap.new(&(&1 < &2))
  ...> |> Heap.pop()
  %FibonacciHeap{
    data: nil,
    size: 0,
    comparator: &(&1 < &2)
  }

  iex> alias FibonacciHeap, as: Heap
  ...> Heap.new(&(&1 < &2))
  ...> |> Heap.push(1)
  ...> |> Heap.pop()
  %FibonacciHeap{
    data: nil,
    size: 0,
    comparator: &(&1 < &2)
  }

  iex> alias FibonacciHeap, as: Heap
  ...> Heap.new(&(&1 < &2))
  ...> |> Heap.push(1)
  ...> |> Heap.push(2)
  ...> |> Heap.pop()
  %FibonacciHeap{
    data: {2, nil},
    size: 1,
    comparator: &(&1 < &2)
  }
  
  """
  def pop(%__MODULE__{data: nil, size: 0} = heap), do: heap
  def pop(%__MODULE__{data: {_v, queue}, size: n, comparator: comp} = heap),
    do: %{heap | data: dequeue(queue, comp), size: n - 1}

  def pop!(%__MODULE__{} = heap), do: {top(heap), pop(heap)}

  @doc """
  ## Examples

  iex> alias FibonacciHeap, as: Heap
  ...> Heap.new(&(&1 < &2))
  ...> |> Heap.push(1)
  %FibonacciHeap{
    data: {1, nil},
    size: 1,
    comparator: &(&1 < &2)
  }

  iex> alias FibonacciHeap, as: Heap
  ...> Heap.new(&(&1 < &2))
  ...> |> Heap.push(1)
  ...> |> Heap.push(2)
  %FibonacciHeap{
    data: {1, [{2, nil}]},
    size: 2,
    comparator: &(&1 < &2)
  }
  
  """
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
          heap, {:cont, v} -> FibonacciHeap.push(heap, v)
          heap, :done -> heap
          _heap, :halt -> :ok
        end
      }
    end
  end

  defimpl Enumerable do
    def count(heap), do: {:ok, FibonacciHeap.size(heap)}
    def member?(_, _), do: {:error, __MODULE__}
    def slice(_), do: {:error, __MODULE__}
    def reduce(_heap, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}
    def reduce(%FibonacciHeap{data: nil, size: 0}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(heap, {:cont, acc}, fun) do
      reduce(FibonacciHeap.pop(heap), fun.(FibonacciHeap.top(heap), acc), fun)
    end
  end
end