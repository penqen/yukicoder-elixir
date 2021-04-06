defmodule Heap do
  defstruct data: nil, comparator: nil
  def new(comparator), do: %__MODULE__{comparator: comparator}

  def empty?(%__MODULE__{data: nil}), do: true
  def empty?(%__MODULE__{}), do: false 

  def size(%__MODULE__{data: nil }), do: 0
  def size(%__MODULE__{data: {_v, _q, r}}), do: r

  def top(%__MODULE__{data: nil}), do: nil
  def top(%__MODULE__{data: {v, _q, _r}}), do: v

  def push(%__MODULE__{data: h,comparator: comp} = heap, v),
  do: %{heap | data: meld(h, {v, [], 1}, comp)}

  defp meld(nil, v, _comp), do: v
  defp meld(v, nil, _comp), do: v
  defp meld({v0, q0, r0} = left , {v1, q1, r1} = right, comp), do: if comp.(v0, v1), do: {v0, [right | q0], r0 + r1}, else: {v1, [left | q1], r0 + r1}

  def pop(%__MODULE__{data: nil} = heap), do: heap
  def pop(%__MODULE__{data: {_v, q, _r}, comparator: comp} = heap),
    do: %{heap | data: prioritize(q, comp)}

  def pop!(%__MODULE__{} = heap), do: {top(heap), pop(heap)}

  def prioritize(queue, compare)
  def prioritize([], _), do: nil
  def prioritize([q], _), do: q
  def prioritize([q0, q1 | q], comp),
    do: meld(meld(q0, q1, comp), prioritize(q, comp), comp)

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