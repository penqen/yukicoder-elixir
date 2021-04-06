defmodule BinaryTupleHeap do
  defstruct data: nil, comparator: nil

  @behaviour Heapable
  @type t() :: %BinaryTupleHeap{}

  @doc """
  ## Examples

    iex> BinaryTupleHeap.new(&(&1 < &2))
    %BinaryTupleHeap{
      data: nil, 
      comparator: &(&1 < &2)
    }

    iex> BinaryTupleHeap.new(&(&1 > &2))
    %BinaryTupleHeap{
      data: nil,
      comparator: &(&1 > &2)
    }

  """
  def new(comparator), do: %__MODULE__{comparator: comparator}

  @doc """
  ## Examples

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.empty?()
    true

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.push(1)
    ...> |> BinaryTupleHeap.empty?()
    false

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.push(1)
    ...> |> BinaryTupleHeap.pop()
    ...> |> BinaryTupleHeap.empty?()
    true

  """
  def empty?(%__MODULE__{data: nil}), do: true
  def empty?(%__MODULE__{}), do: false 

    @doc """
  ## Examples

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.size()
    0

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.push(1)
    ...> |> BinaryTupleHeap.size()
    1

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.push(1)
    ...> |> BinaryTupleHeap.pop()
    ...> |> BinaryTupleHeap.size()
    0
    
    iex> 1..10
    ...> |> Enum.into(BinaryTupleHeap.new(&(&1 < &2)))
    ...> |> BinaryTupleHeap.size()
    10

    iex> 1..10
    ...> |> Enum.into(BinaryTupleHeap.new(&(&1 < &2)))
    ...> |> BinaryTupleHeap.pop()
    ...> |> BinaryTupleHeap.size()
    9 

  """
  def size(%__MODULE__{data: nil}), do: 0
  def size(%__MODULE__{data: {size, _value, _left, _right}}), do: size

    @doc """
  ## Examples

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.top()
    nil

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.push(1)
    ...> |> BinaryTupleHeap.top()
    1

    iex> 1..10
    ...> |> Enum.into(BinaryTupleHeap.new(&(&1 < &2)))
    ...> |> BinaryTupleHeap.top()
    1

    iex> 1..10
    ...> |> Enum.into(BinaryTupleHeap.new(&(&1 < &2)))
    ...> |> BinaryTupleHeap.pop()
    ...> |> BinaryTupleHeap.top()
    2

    iex> 1..10
    ...> |> Enum.into(BinaryTupleHeap.new(&(&1 > &2)))
    ...> |> BinaryTupleHeap.top()
    10 

    iex> 1..10
    ...> |> Enum.into(BinaryTupleHeap.new(&(&1 > &2)))
    ...> |> BinaryTupleHeap.pop()
    ...> |> BinaryTupleHeap.top()
    9 

  """
  def top(%__MODULE__{data: nil}), do: nil
  def top(%__MODULE__{data: {_size, value, _left, _right}}), do: value

  @doc """
  ## Examples

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.pop()
    %BinaryTupleHeap{data: nil, comparator: &(&1 < &2)}

    iex> BinaryTupleHeap.new(&(&1 < &2))
    ...> |> BinaryTupleHeap.push(1)
    ...> |> BinaryTupleHeap.pop()
    %BinaryTupleHeap{data: nil, comparator: &(&1 < &2)}

    iex> 1..5
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryTupleHeap.new(&(&1 < &2))
    ...> )
    ...> |> Enum.to_list()
    [1, 2, 3, 4, 5]

    iex> 1..10
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryTupleHeap.new(&(&1 < &2))
    ...> )
    ...> |> Enum.to_list()
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    iex> 1..5
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryTupleHeap.new(&(&1 > &2))
    ...> )
    ...> |> Enum.to_list()
    [5, 4, 3, 2, 1]

    iex> 1..10
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryTupleHeap.new(&(&1 > &2))
    ...> )
    ...> |> Enum.to_list()
    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

  """
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


  @doc """
  ## Examples

  iex> BinaryTupleHeap.new(&(&1 < &2))
  ...> |> BinaryTupleHeap.push(1)
  %BinaryTupleHeap{
    data: {1, 1, nil, nil},
    comparator: &(&1 < &2)
  }
  
  iex> 1..5
  ...> |> Enum.shuffle()
  ...> |> Enum.into(
  ...>   BinaryTupleHeap.new(&(&1 < &2))
  ...> )
  ...> |> BinaryTupleHeap.size()
  5
  
  iex> 1..10
  ...> |> Enum.shuffle()
  ...> |> Enum.into(
  ...>   BinaryTupleHeap.new(&(&1 < &2))
  ...> )
  ...> |> BinaryTupleHeap.size()
  10

  """
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
    @spec into(BinaryTupleHeap.t()) :: {list, function}
    def into(heap) do
      {
        heap,
        fn
          heap, {:cont, v} -> BinaryTupleHeap.push(heap, v)
          heap, :done -> heap
          _heap, :halt -> :ok
        end
      }
    end
  end

  defimpl Enumerable do
    @spec count(BinaryTupleHeap.t()) :: non_neg_integer()
    def count(heap), do: {:ok, BinaryTupleHeap.size(heap)}
  
    @spec member?(BinaryTupleHeap.t(), term()) ::  {:error, module()}
    def member?(_, _), do: {:error, __MODULE__}
  
    @spec slice(BinaryTupleHeap.t()) :: {:error, module()}
    def slice(_), do: {:error, __MODULE__}
  
    @spec reduce(BinaryTupleHeap.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
    def reduce(_heap, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}
    def reduce(%BinaryTupleHeap{data: nil}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(heap, {:cont, acc}, fun) do
      reduce(BinaryTupleHeap.pop(heap), fun.(BinaryTupleHeap.top(heap), acc), fun)
    end
  end
end