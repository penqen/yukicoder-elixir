defmodule P1 do
  @moduledoc """
  ## Examples
    iex> P1.solve(3, 100, 3, [1, 2, 1], [2, 3, 3], [10, 90, 10], [10, 10, 50])
    20

    iex> P1.solve(3, 100, 3, [1, 2, 1], [2, 3, 3], [1, 100, 10], [10, 10, 50])
    50
    
    iex> P1.solve(10, 10, 19,
    ...>  [1, 1, 2, 4, 5, 1, 3, 4, 6, 4, 6, 4, 5, 7, 8, 2, 3, 4, 9],
    ...>  [3, 5, 5, 5, 6, 7, 7, 7, 7, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10],
    ...>  [8, 6, 8, 7, 6, 6, 9, 9, 7, 6, 9, 7, 7, 8, 7, 6, 6, 8, 6],
    ...>  [8, 9, 10, 4, 10, 3, 5, 9, 3, 4, 1, 8, 3, 1, 3, 6, 6, 10, 4]
    ...>)
    -1 
  """ 

  alias Matrix
  alias BinaryTupleHeap, as: Heap

  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    c = IO.read(:line) |> String.trim() |> String.to_integer()
    v = IO.read(:line) |> String.trim() |> String.to_integer()
    sn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    tn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    yn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    mn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(n, c, v, sn, tn, yn, mn) |> IO.puts()
  end

  @doc """
  初期位置: n = 1
  Goal: N
  n : 町番号
  c : 最大コスト(円)
  v : 道の数
  sv : 町番号リスト
  tv : 町番号リスト
  yv : si から ti へ行くのにかかるお金
  mv : si から ti へ行くのにかかる単位時間

  # Output

  最短時間を返す。制約条件内で存在しない場合は、-1を返す。

  """
  def solve(n, c, v, sv, tv, yv, mv)
  def solve(n, c, v, sv, tv, yv, mv) when 2 <= n and n <= 50 and
    1 <= c and c <= 300 and
    length(sv) == v and
    length(tv) == v and
    length(yv) == v and
    length(mv) == v
  do
    with [] <- Enum.filter(mv, &(not(1 <= &1 and &1 <= 1000))) do
      fn {_ln, ly, lm}, {_rn, ry, rm} ->
        lm < rm || (lm == rm && ly < ry)
      end
      |> Heap.new()
      |> Heap.push({1, 0, 0})
      |> do_solve(n, c, build_cost_map(sv, tv, yv, mv))
    else
      _ ->
        -1
    end
  end

  def solve(_n, _c, _v, _sv, _tv, _yv, _mv), do: -1

  defp do_solve(heap, goal, max_cost, cost_map) do
    with false <- Heap.empty?(heap),
      {g, y, t} when g == goal and y <= max_cost <- Heap.top(heap) do
        t
    else
      true ->
        -1
      nil ->
        -1
      {current_node, current_yen, current_time} ->
        heap = Heap.pop(heap)

        cost_map
        |> Map.get(current_node)
        |> case do
          nil ->
            heap
          map ->
            map
            |> Map.keys()
            |> Enum.reduce(heap, fn next_node, heap ->
              Matrix.get(cost_map, [current_node, next_node])
              |> Enum.reduce(heap, fn {yen, time}, heap ->
                Heap.push(heap, {next_node, current_yen + yen, current_time + time})
              end)
            end)
        end
        |> do_solve(goal, max_cost, cost_map)
    end
  end

  def build_cost_map(sv, tv, yv, mv), do: do_build_cost_map(sv, tv, yv, mv)
  defp do_build_cost_map(sv, tv, yv, mv, map \\ %{})
  defp do_build_cost_map([], [], [], [], map), do: map
  defp do_build_cost_map([s | sv], [t | tv], [y | yv], [m | mv], map) do
    if s < t do
      with nil <- Matrix.get(map, [s, t]) do
        do_build_cost_map(sv, tv, yv, mv, Matrix.put(map, [s, t], [{y, m}]))
      else
        list ->
          do_build_cost_map(sv, tv, yv, mv, Matrix.put(map, [s, t], [{y, m} | list]))
      end
    else
      do_build_cost_map(sv, tv, yv, mv)
    end
  end
end

"""
defmodule Main do
  defmodule Matrix do
    def put(map, keys, value), do: do_map_put(value, keys, map)
  
    defp do_map_put(value, keys, map)
    defp do_map_put(value, [], _), do: value
    defp do_map_put(value, [key | tail], nil), do: Map.put(%{}, key, do_map_put(value, tail, Map.get(%{}, key)))
    defp do_map_put(value, [key | tail], map), do: Map.put(map, key, do_map_put(value, tail, Map.get(map, key)))
  
    def get(map, key_or_keys)
    def get(nil, _key), do: nil
    def get(map, [key | []]), do: Map.get(map, key)
    def get(map, [key | tail]), do: get(Map.get(map, key), tail)
    def get(map, key), do: Map.get(map, key)
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
  end

  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    c = IO.read(:line) |> String.trim() |> String.to_integer()
    v = IO.read(:line) |> String.trim() |> String.to_integer()
    sn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    tn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    yn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    mn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(n, c, v, sn, tn, yn, mn) |> IO.puts()
  end

  def solve(n, c, _v, sv, tv, yv, mv) do
    fn {_ln, ly, lm}, {_rn, ry, rm} ->
      lm < rm || (lm == rm && ly < ry)
    end
    |> Heap.new()
    |> Heap.push({1, 0, 0})
    |> do_solve(n, c, build_cost_map(sv, tv, yv, mv))
  end

  defp do_solve(heap, goal, max_cost, cost_map) do
    with false <- Heap.empty?(heap),
      {g, y, t} when g == goal and y <= max_cost <- Heap.top(heap) do
        t
    else
      true ->
        -1
      nil ->
        -1
      {current_node, current_yen, current_time} ->
        heap = Heap.pop(heap)

        cost_map
        |> Map.get(current_node)
        |> case do
          nil ->
            heap
          map ->
            map
            |> Map.keys()
            |> Enum.reduce(heap, fn next_node, heap ->
              Matrix.get(cost_map, [current_node, next_node])
              |> Enum.reduce(heap, fn {yen, time}, heap ->
                Heap.push(heap, {next_node, current_yen + yen, current_time + time})
              end)
            end)
        end
        |> do_solve(goal, max_cost, cost_map)
    end
  end

  def build_cost_map(sv, tv, yv, mv), do: do_build_cost_map(sv, tv, yv, mv)
  defp do_build_cost_map(sv, tv, yv, mv, map \\ %{})
  defp do_build_cost_map([], [], [], [], map), do: map
  defp do_build_cost_map([s | sv], [t | tv], [y | yv], [m | mv], map) do
    if s < t do
      with nil <- Matrix.get(map, [s, t]) do
        do_build_cost_map(sv, tv, yv, mv, Matrix.put(map, [s, t], [{y, m}]))
      else
        list ->
          do_build_cost_map(sv, tv, yv, mv, Matrix.put(map, [s, t], [{y, m} | list]))
      end
    else
      do_build_cost_map(sv, tv, yv, mv)
    end
  end
end
defmodule Main do
  defmodule Matrix do
    def put(map, keys, value), do: do_map_put(value, keys, map)
  
    defp do_map_put(value, keys, map)
    defp do_map_put(value, [], _), do: value
    defp do_map_put(value, [key | tail], nil), do: Map.put(%{}, key, do_map_put(value, tail, Map.get(%{}, key)))
    defp do_map_put(value, [key | tail], map), do: Map.put(map, key, do_map_put(value, tail, Map.get(map, key)))
  
    def get(map, key_or_keys)
    def get(nil, _key), do: nil
    def get(map, [key | []]), do: Map.get(map, key)
    def get(map, [key | tail]), do: get(Map.get(map, key), tail)
    def get(map, key), do: Map.get(map, key)
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
  end

  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    c = IO.read(:line) |> String.trim() |> String.to_integer()
    v = IO.read(:line) |> String.trim() |> String.to_integer()
    sn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    tn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    yn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    mn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(n, c, v, sn, tn, yn, mn) |> IO.puts()
  end

  def solve(n, c, _v, sv, tv, yv, mv) do
    fn {_ln, ly, lm}, {_rn, ry, rm} ->
      lm < rm || (lm == rm && ly < ry)
    end
    |> Heap.new()
    |> Heap.push({1, 0, 0})
    |> do_solve(n, c, build_cost_map(sv, tv, yv, mv))
  end

  defp do_solve(heap, goal, max_cost, cost_map) do
    with false <- Heap.empty?(heap),
      {g, y, t} when g == goal and y <= max_cost <- Heap.top(heap) do
        t
    else
      true ->
        -1
      nil ->
        -1
      {current_node, current_yen, current_time} ->
        heap = Heap.pop(heap)

        cost_map
        |> Map.get(current_node)
        |> case do
          nil ->
            heap
          map ->
            map
            |> Map.keys()
            |> Enum.reduce(heap, fn next_node, heap ->
              Matrix.get(cost_map, [current_node, next_node])
              |> Enum.reduce(heap, fn {yen, time}, heap ->
                Heap.push(heap, {next_node, current_yen + yen, current_time + time})
              end)
            end)
        end
        |> do_solve(goal, max_cost, cost_map)
    end
  end

  def build_cost_map(sv, tv, yv, mv), do: do_build_cost_map(sv, tv, yv, mv)
  defp do_build_cost_map(sv, tv, yv, mv, map \\ %{})
  defp do_build_cost_map([], [], [], [], map), do: map
  defp do_build_cost_map([s | sv], [t | tv], [y | yv], [m | mv], map) do
    if s < t do
      with nil <- Matrix.get(map, [s, t]) do
        do_build_cost_map(sv, tv, yv, mv, Matrix.put(map, [s, t], [{y, m}]))
      else
        list ->
          do_build_cost_map(sv, tv, yv, mv, Matrix.put(map, [s, t], [{y, m} | list]))
      end
    else
      do_build_cost_map(sv, tv, yv, mv)
    end
  end
end
"""