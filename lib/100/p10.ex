defmodule P10 do
  @moduledoc """
  - 入力: N, Total, A[n]
  - 複数回答の場合 {+,*} の順の辞書列順の最初
  - (((((A[0]) ? A[1]) ? A[2]) ? A[3]) ... A[n - 1]) = Total

  以下の関係式を考える。 このとき、`?`オペランドは、`{/,-}`である。

  ```
  R(n) = Total
  R(n - 1) = R(n) ? A[n - 1]
  R(n - 2) = R(n - 1) ? A[n - 2]
  ...
  R(i) = R(i - 1) ? A[i]
  ...
  R(1) = R(2) ? A[1] = A[0]
  ```

  このとき、`?`オペランドが`/`のとき、 

  ```
  R(i - 1) mod A[i] = 0
  ```

  を満たす必要があるため、事前に枝刈りが可能である。

  また、`A[0] 〜 A[i]` までの取り得る最大値を利用し、`R(i)`の上界を得ることができる。

  上記の計算を実現する方法ために、`key`が`R(i)`、`value`が`R(i)を満たすオペランド列の配列`となる`Map`を使う。

  オペランドの表現方法は、ビット列を使い、`R(i)`のオペランドのビットは`n - i`番目となるようにする。
  `+,*`をそれぞれ`1,0`とすると、A[0]と同値となるオペランド列の中から最大値となるビット列が求めるオペランド列となる。
  例えば、`010`は、`*+*`となる。

  また、同値となる`R(i)`のオペランドが`*`のときだけ、候補となるビット列の全てを候補に入れる必要はなく、辞書順である最大値のビット列だけを考慮に入れればいい。

  ```
  n = 4
  total = 31
  an = [1, 2, 10, 1]

  upperbound = %{0 => 31, 1 => 21, 2 => 11, 3 => 1}

  R(n) = %{ total => 0 } = %{ 31 => 1 }

  %{30 => [1], 31 => [0]}
  %{3 => [1], 20 => [3], 21 => [2]}
  %{1 => [5], 10 => [3]}

  R(n) => %{ total => 0 }
  R(n)
  ```

  # Examples

    iex> P10.solve(4, 31, [1, 2, 10, 1])
    "+*+"

    -iex> P10.solve(3, 6, [2, 3, 1])
    -"++"

    -iex> P10.solve(3, 2, [1, 1, 2])
    -"**"

    -iex> P10.solve(6, 672, [1, 1, 3, 8, 3, 7])
    -"*+***"

    -iex> P10.solve(21, 83702, [5, 9, 3, 7, 2, 7, 1, 4, 8, 7, 5, 2, 9, 2, 6, 8, 7, 9, 5, 2, 5])
    -"+*+*+++++++**++*+*++"
 
    -iex> P10.solve(26, 36477, [9, 4, 2, 7, 1, 6, 1, 6, 9, 2, 10, 4, 10, 10, 10, 5, 7, 4, 5, 1, 7, 9, 4, 7, 1, 9])
    -"++++*+++++++*+++**+++++*+"

    -iex> n = 50
    -...> total = 100000
    -...> an = [4, 6, 1, 8, 10, 2, 6, 4, 8, 9, 10, 8, 2, 1, 9, 5, 9, 1, 4, 1, 1, 6, 1, 9, 10, 9, 2, 7, 3, 8, 1, 4, 2, 7, 6, 10, 8, 7, 5, 5, 4, 2, 10, 8, 4, 8, 9, 5, 5, 9]
    -...> P10.solve(n, total, an)
    -"++++++++++++++++++**+*+*+*++++++++*++++*+++++++++"

    -iex> n = 50
    -...> total = 65536
    -...> an = [2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
    -...> P10.solve(n, total, an)
    -"+++**++++++++++++++++++++++++++++++++************"
  """
  use Bitwise, only_operators: true
  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    total = IO.read(:line) |> String.trim() |> String.to_integer()
    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(n, total, an) |> IO.puts()
  end

  def solve(n, total, an) do
    {_, ub} = Enum.reduce(0..(n - 1), {an, %{}}, fn i, {[a | an], ub} ->
      {an, Map.put(ub, i, Enum.reduce(an, a, &(:erlang.max(&1 * &2, &1 + &2))))}
    end)
    |> IO.inspect
    [a | an] = an
    an
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(Map.put(%{}, total, [0]), fn {_a, i} = step, dp ->
      #Enum.reduce(dp, %{}, &(&2 |> times(&1, step, ub[i]) |> plus(&1, step, ub[i])))
      Enum.reduce(dp, %{}, fn {_rest, _wi} = before_step, ndp ->
        ndp
        |> times(before_step, step, ub[i])
        |> plus(before_step, step, ub[i])
      end)
      |> IO.inspect
    end)
    |> Map.get(a)
    |> Enum.max()
    |> restore(n)
    |> Enum.reverse()
    |> Enum.join("")
  end

  def times(dp, {rest, wi}, {a, _i}, ub) do
    if :math.fmod(rest, a) == 0, do: update(dp, div(rest, a), [Enum.max(wi)], ub), else: dp
  end
  def plus(dp, {rest, wi}, {a, i}, ub) when a <= rest,
   do: update(dp, rest - a, Enum.map(wi, fn w -> w + (1 <<< i) end), ub)
  def plus(dp, {_rest, _wi}, {_a, _i}, _ub), do: dp

  def update(dp, key, wi, ub) when key <= ub, do: Map.update(dp, key, wi, fn q -> wi ++ q end)
  def update(dp, _key, _wi, _ub), do: dp

  @doc """
  辞書順に重み付けする方法:

  i を深さとし、重みw_iは、以下のように設定する。

  :+ => w_i = 1 + w_i << 2
  :* => w_i = 0 + w_i << 2

  """
  def solve_bfs(n, total, an) do
    [a | an] = an
    an
    |> Enum.reduce(Map.put(%{}, a, 0), fn a, dp ->
      Enum.reduce(dp, %{}, fn {acc, wi}, ndp ->

        ndp
        |> put(acc + a, (wi <<< 1) + 1, total)
        |> put(acc * a, (wi <<< 1), total)
      end)
    end)
    |> (fn dp ->
      dp[total] |> restore(n) |> Enum.reverse() |> Enum.join("")
    end).()
  end

  def restore(_w, 1), do: []
  def restore(w, i) do
    [(if (w &&& 1) == 1, do: :+, else: :*) | restore(w >>> 1 ,i - 1)]
  end

  def put(dp, key, value, total) when key <= total do
    if is_nil(dp[key]) || dp[key] < value,do: Map.put(dp, key, value), else: dp
  end
  def put(dp, _key, _value, _total), do: dp
end

# 早いやつ
#defmodule Main do
#  use Bitwise, only_operators: true
#  def main do
#    n = IO.read(:line) |> String.trim() |> String.to_integer()
#    total = IO.read(:line) |> String.trim() |> String.to_integer()
#    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
#    {_, ub} = Enum.reduce(0..(n - 1), {an, %{}}, fn i, {[a | an], ub} ->
#      {an, Map.put(ub, i, Enum.reduce(an, a, &(:erlang.max(&1 * &2, &1 + &2))))}
#    end)
#    [a | an] = an
#    an
#    |> Enum.reverse() |> Enum.with_index()
#    |> Enum.reduce(Map.put(%{}, total, [0]), fn {_a, i} = step, dp ->
#      Enum.reduce(dp, %{}, &(&2 |> times(&1, step, ub[i]) |> plus(&1, step, ub[i])))
#    end)
#    |> Map.get(a) |> Enum.max() |> restore(n) |> Enum.reverse() |> Enum.join("") |> IO.puts()
#  end
#  def times(dp, {rest, wi}, {a, _i}, ub),
#   do: if :math.fmod(rest, a) == 0, do: update(dp, div(rest, a), [Enum.max(wi)], ub), else: dp
#  def plus(dp, {rest, wi}, {a, i}, ub) when a <= rest,
#   do: update(dp, rest - a, Enum.map(wi, fn w -> w + (1 <<< i) end), ub)
#  def plus(dp, {_rest, _wi}, {_a, _i}, _ub), do: dp
#  def update(dp, key, wi, ub) when key <= ub, do: Map.update(dp, key, wi, fn q -> wi ++ q end)
#  def update(dp, _key, _wi, _ub), do: dp
#  def restore(_w, 1), do: []
#  def restore(w, i), do: [(if (w &&& 1) == 1, do: :+, else: :*) | restore(w >>> 1 ,i - 1)]
#end

# 遅いやつ
#defmodule Main do
#  use Bitwise
#  def main do
#    n = IO.read(:line) |> String.trim() |> String.to_integer()
#    total = IO.read(:line) |> String.trim() |> String.to_integer()
#    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
#    solve(n, total, an) |> IO.puts()
#  end
#
#  def solve(n, total, an) do
#    [a | an] = an
#    an
#    |> Enum.reduce(Map.put(%{}, a, 0), fn a, dp ->
#      Enum.reduce(dp, %{}, fn {acc, wi}, ndp ->
#        ndp |> put(acc + a, (wi <<< 1) + 1, total) |> put(acc * a, (wi <<< 1), total)
#      end)
#    end)
#    |> (fn dp ->
#      dp[total] |> restore(n) |> Enum.reverse() |> Enum.join("")
#    end).()
#  end
#
#  def restore(_w, 1), do: []
#  def restore(w, i), do: [(if (w &&& 1) == 1, do: :+, else: :*) | restore(w >>> 1 ,i - 1)]
#
#  def put(dp, key, value, total) when key <= total,
#   do: if is_nil(dp[key]) || dp[key] < value, do: Map.put(dp, key, value), else: dp
#  def put(dp, _key, _value, _total), do: dp
#end