defmodule BinaryHeap do
  defstruct data: [], comparator: nil

  @moduledoc """
  BinaryHeapの実装

  ## ノード `n` (ノード番号０から開始)
  `parent node`     : div(n - 1, 2)
  `children node`   : 2n + 1, 2n + 2

  ## ノード `n` (ノード番号1から開始)
  `parent node`     : div(n, 2)
  `children node`   : 2n, 2n + 1

  """

  @behaviour Heapable

  @type t() :: %BinaryHeap{}

  @doc """
  ## Examples

    iex> BinaryHeap.new(&(&1 < &2))
    %BinaryHeap{
      data: [],
      comparator: &(&1 < &2)
    }

    iex> BinaryHeap.new(&(&1 > &2))
    %BinaryHeap{
      data: [],
      comparator: &(&1 > &2)
    }

  """
  def new(comparator), do: %__MODULE__{comparator: comparator}

  @doc """
  ## Examples

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.empty?()
    true

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.push(1)
    ...> |> BinaryHeap.empty?()
    false

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.push(1)
    ...> |> BinaryHeap.pop()
    ...> |> BinaryHeap.empty?()
    true

  """
  def empty?(%__MODULE__{data: []}), do: true
  def empty?(%__MODULE__{}), do: false 

  @doc """
  ## Examples

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.size()
    0

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.push(1)
    ...> |> BinaryHeap.size()
    1

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.push(1)
    ...> |> BinaryHeap.pop()
    ...> |> BinaryHeap.size()
    0
    
    iex> 1..10
    ...> |> Enum.into(BinaryHeap.new(&(&1 < &2)))
    ...> |> BinaryHeap.size()
    10

    iex> 1..10
    ...> |> Enum.into(BinaryHeap.new(&(&1 < &2)))
    ...> |> BinaryHeap.pop()
    ...> |> BinaryHeap.size()
    9 

  """
  def size(%__MODULE__{data: data}) do
    length(data)
  end
 
  @doc """
  ## Examples

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.top()
    nil

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.push(1)
    ...> |> BinaryHeap.top()
    1

    iex> 1..10
    ...> |> Enum.into(BinaryHeap.new(&(&1 < &2)))
    ...> |> BinaryHeap.top()
    1

    iex> 1..10
    ...> |> Enum.into(BinaryHeap.new(&(&1 < &2)))
    ...> |> BinaryHeap.pop()
    ...> |> BinaryHeap.top()
    2

    iex> 1..10
    ...> |> Enum.into(BinaryHeap.new(&(&1 > &2)))
    ...> |> BinaryHeap.top()
    10 

    iex> 1..10
    ...> |> Enum.into(BinaryHeap.new(&(&1 > &2)))
    ...> |> BinaryHeap.pop()
    ...> |> BinaryHeap.top()
    9 

  """
  def top(%__MODULE__{data: []}), do: nil
  def top(%__MODULE__{data: [t | _]}), do: t
  

  @doc """
  ## Examples

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.pop()
    nil

    iex> BinaryHeap.new(&(&1 < &2))
    ...> |> BinaryHeap.push(1)
    ...> |> BinaryHeap.pop()
    %BinaryHeap{data: [], comparator: &(&1 < &2)}

    iex> 1..5
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryHeap.new(&(&1 < &2))
    ...> )
    ...> |> Enum.to_list()
    [1, 2, 3, 4, 5]

    iex> 1..10
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryHeap.new(&(&1 < &2))
    ...> )
    ...> |> Enum.to_list()
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    iex> 1..5
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryHeap.new(&(&1 > &2))
    ...> )
    ...> |> Enum.to_list()
    [5, 4, 3, 2, 1]

    iex> 1..10
    ...> |> Enum.shuffle()
    ...> |> Enum.into(
    ...>   BinaryHeap.new(&(&1 > &2))
    ...> )
    ...> |> Enum.to_list()
    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

  """
  def pop(%__MODULE__{data: []}), do: nil
  def pop(%__MODULE__{data: [_]} = heap), do: %{ heap | data: []}
  def pop(%__MODULE__{data: [_ | tail], comparator: comp} = heap) do
    %{
      heap |
      data: do_pop([List.last(tail) | List.delete_at(tail, -1)], comp)
    }
  end

  defp do_pop(data, comp, n \\ 0) do
    parent = Enum.at(data, n)
    left_index = index(:left_child, n)
    right_index = index(:right_child, n)

    {Enum.at(data, left_index), Enum.at(data, right_index)}
    |> case do
      {nil, nil} ->
        data
      {left, nil} ->
        if comp.(parent, left), do: data, else: {left_index, left}
      {left, right} ->
        if comp.(left, right) do
          if comp.(parent, left), do: data, else: {left_index, left}
        else
          if comp.(parent, right), do: data, else: {right_index, right}
        end
    end
    |> case do
      {index, value} ->
        data
        |> List.replace_at(index, parent)
        |> List.replace_at(n, value)
        |> do_pop(comp, index)
      data when is_list(data) ->
        data
    end
  end


  @doc """
  ## Examples

  iex> BinaryHeap.new(&(&1 < &2))
  ...> |> BinaryHeap.push(1)
  %BinaryHeap{
    data: [1],
    comparator: &(&1 < &2)
  }
  
  iex> 1..5
  ...> |> Enum.shuffle()
  ...> |> Enum.into(
  ...>   BinaryHeap.new(&(&1 < &2))
  ...> )
  ...> |> BinaryHeap.size()
  5
  
  iex> 1..10
  ...> |> Enum.shuffle()
  ...> |> Enum.into(
  ...>   BinaryHeap.new(&(&1 < &2))
  ...> )
  ...> |> BinaryHeap.size()
  10

  """
  def push(%__MODULE__{data: data, comparator: comp} = heap, value) do
    arr = data ++ [value]

    %{
      heap |
      data: do_push(arr, length(arr) - 1, comp)
    }
  end

  defp do_push(arr, n, comp)
  defp do_push(arr, 0, _comp), do: arr
  defp do_push(arr, n, comp) do
    pi = index(:parent, n)
    parent = Enum.at(arr, pi)
    child = Enum.at(arr, n)

    if (comp.(parent, child)) do
      arr
    else
      arr
      |> List.replace_at(pi, child)
      |> List.replace_at(n, parent)
      |> do_push(pi, comp)
    end
  end

  defp index(:parent, n), do: div(n, 2)
  defp index(:left_child, n),   do: 2 * n + 1
  defp index(:right_child, n),  do: 2 * n + 2

  defimpl Collectable do
    @spec into(BinaryHeap.t()) :: {list, function}
    def into(heap) do
      {
        heap,
        fn
          heap, {:cont, v} -> BinaryHeap.push(heap, v)
          heap, :done -> heap
          _heap, :halt -> :ok
        end
      }
    end
  end

  defimpl Enumerable do
    @spec count(BinaryHeap.t()) :: non_neg_integer()
    def count(heap), do: {:ok, BinaryHeap.size(heap)}
  
    @spec member?(BinaryHeap.t(), term()) ::  {:error, module()}
    def member?(_, _), do: {:error, __MODULE__}
  
    @spec slice(BinaryHeap.t()) :: {:error, module()}
    def slice(_), do: {:error, __MODULE__}
  
    @spec reduce(BinaryHeap.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
    def reduce(_heap, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}
    def reduce(%BinaryHeap{data: []}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(heap, {:cont, acc}, fun) do
      reduce(BinaryHeap.pop(heap), fun.(BinaryHeap.top(heap), acc), fun)
    end
  end
end