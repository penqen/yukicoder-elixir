defmodule P6 do
  @moduledoc """
  [K, N]区間内の素数に対して、尺取り法を用いて、ハッシュ関数を満たす最大数列を探す。

  # Examples
    > P6.solve(2, 2)
    2

    > P6.solve(1, 11)
    3

    > P6.solve(10, 100)
    31
  """
  import Integer, only: [is_odd: 1]

  def main do
    k = IO.read(:line) |> String.trim() |> String.to_integer()
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    solve(k, n) |> IO.puts
  end

  defmodule Prime do
    defstruct value: 2

    def next(prime \\ %__MODULE__{value: 2})
    def next(%__MODULE__{value: 2}), do: %__MODULE__{value: 3}
    def next(%__MODULE__{value: n} = prime) do
      if is_prime(n + 2),
        do: %{prime | value: n + 2},
        else: next(%{prime | value: n + 2})
    end

    def first(1), do: 2
    def first(2), do: 2
    def first(3), do: 3
    def first(n) when is_odd(n) do
      if is_prime(n), do: n, else: first(n + 2)
    end
    def first(n), do: first(n + 1)

    @doc """
    素数を判定する。

    # Examples

      iex> Prime.is_prime(1)
      false

      iex> [2, 3, 5, 7, 11, 13, 17, 19]
      ...> |> Enum.map(&P2.is_prime/1)
      [true, true, true, true, true, true, true, true]

      iex> Prime.is_prime(4)
      false

      iex> Prime.is_prime(24)
      false

      iex> Prime.is_prime(58)
      false

    """
    def is_prime(n)
    def is_prime(n) when n < 2, do: false
    def is_prime(2), do: true
    def is_prime(3), do: true
    def is_prime(n) when 3 < n do
      if rem(n, 2) == 0, do: false, else: is_prime(n, 3)
    end
    defp is_prime(n, i) when i * i <= n do
      if rem(n, i) == 0, do: false, else: is_prime(n, i + 2)
    end
    defp is_prime(_, _), do: true

    defimpl Enumerable do
      def count(_), do: {:error, __MODULE__}
      def member?(_, _), do: {:error, __MODULE__}
      def slice(_), do: {:error, __MODULE__}
      def reduce(_prime, {:halt, acc}, _fun), do: {:halted, acc}
      def reduce(prime, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(prime, &1, fun)}
      def reduce(%{value: v} = prime, {:cont, acc}, fun) do
        reduce(Prime.next(prime), fun.(v, acc), fun)
      end
    end
  end

  def solve(k, n) do
    %Prime{value: Prime.first(k)}
    |> Enum.reduce_while({%{}, nil, nil}, fn
      prime, acc when n < prime ->
        {:halt, acc}
      prime, {memo, nil, max} ->
        memo = Map.put(memo, prime, MapSet.new([frank_hash(prime)]))
        {:cont, {memo, [prime], max}}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            memo = Map.put(memo, target, MapSet.put(memo[target], hashed_value))
            {memo, max, complete}
          end
        end)
        {
          :cont,
          {
            Enum.reduce(complete, memo, fn
              v, memo when v == max -> memo
              v, memo -> Map.delete(memo, v)
            end),
            Enum.reject([prime | start_with], fn v -> v in complete end),
            max
          }
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  def frank_hash(n) when n < 10, do: n
  def frank_hash(n), do: n |> Integer.digits() |> Enum.sum() |> frank_hash()

 
  @doc """
  Streamを使って、逐次を取り出す方法。
  """
  def stream(n, k) do
    n..k
    |> Stream.filter(fn v -> Prime.is_prime(v) end)
    |> Enum.reduce({%{}, nil, nil}, fn 
      prime, {memo, nil, max} ->
        memo = Map.put(memo, prime, MapSet.new([frank_hash(prime)]))
        {memo, [prime], max}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            memo = Map.put(memo, target, MapSet.put(memo[target], hashed_value))
            {memo, max, complete}
          end
        end)
        {
          Enum.reduce(complete, memo, fn
            v, memo when v == max -> memo
            v, memo -> Map.delete(memo, v)
          end),
          Enum.reject([prime | start_with], fn v -> v in complete end),
          max
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  @doc """
  予め範囲内の素数をリスト化する方法
  """
  def prime(n, k) do
    %Prime{}
    |> to_list([], n, k)
    |> Enum.reduce({%{}, nil, nil}, fn 
      prime, {memo, nil, max} ->
        memo = Map.put(memo, prime, MapSet.new([frank_hash(prime)]))
        {memo, [prime], max}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            memo = Map.put(memo, target, MapSet.put(memo[target], hashed_value))
            {memo, max, complete}
          end
        end)
        {
          Enum.reduce(complete, memo, fn
            v, memo when v == max -> memo
            v, memo -> Map.delete(memo, v)
          end),
          Enum.reject([prime | start_with], fn v -> v in complete end),
          max
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  @doc """
  k以上の素数を予め求め、そこからStreamを用いて素数を取り出す方法
  """
  def prime_n(k, n) do
    %Prime{value: Prime.first(k)}
    |> Stream.take_while(&(&1 <= n))
    |> Enum.reduce({%{}, nil, nil}, fn 
      prime, {memo, nil, max} ->
        memo = Map.put(memo, prime, MapSet.new([frank_hash(prime)]))
        {memo, [prime], max}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            memo = Map.put(memo, target, MapSet.put(memo[target], hashed_value))
            {memo, max, complete}
          end
        end)
        {
          Enum.reduce(complete, memo, fn
            v, memo when v == max -> memo
            v, memo -> Map.delete(memo, v)
          end),
          Enum.reject([prime | start_with], fn v -> v in complete end),
          max
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  @doc """
  これが総合的に早そう。
  Streamを挟まず、`Enum.reduce_while/3`を用いて、素数を求めると同時に計算する方法
  """
  def prime_w(k, n) do
    %Prime{value: Prime.first(k)}
    |> Enum.reduce_while({%{}, nil, nil}, fn
      prime, acc when n < prime ->
        {:halt, acc}
      prime, {memo, nil, max} ->
        memo = Map.put(memo, prime, MapSet.new([frank_hash(prime)]))
        {:cont, {memo, [prime], max}}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            memo = Map.put(memo, target, MapSet.put(memo[target], hashed_value))
            {memo, max, complete}
          end
        end)
        {
          :cont,
          {
            Enum.reduce(complete, memo, fn
              v, memo when v == max -> memo
              v, memo -> Map.delete(memo, v)
            end),
            Enum.reject([prime | start_with], fn v -> v in complete end),
            max
          }
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  @doc """
  Streamを挟まず、`Enum.reduce_while/3`を用いて、素数を求めると同時に計算する方法
  それに加え、不要となった辞書の削除を行わない方法
  """
  def prime_d(k, n) do
    %Prime{value: Prime.first(k)}
    |> Enum.reduce_while({%{}, nil, nil}, fn
      prime, acc when n < prime ->
        {:halt, acc}
      prime, {memo, nil, max} ->
        memo = Map.put(memo, prime, MapSet.new([frank_hash(prime)]))
        {:cont, {memo, [prime], max}}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            memo = Map.put(memo, target, MapSet.put(memo[target], hashed_value))
            {memo, max, complete}
          end
        end)
        {:cont,
          {
            memo,
            Enum.reject([prime | start_with], fn v -> v in complete end),
            max
          }
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  def to_list(%Prime{value: v} = p, [], n, k) when v < n, do: to_list(Prime.next(p), [], n, k)
  def to_list(%Prime{value: v}, l, _n, k) when k < v, do: l |> Enum.reverse()
  def to_list(%Prime{value: v} = p, l, n, k), do: to_list(Prime.next(p), [v | l], n, k)
end

"""
defmodule Main do
  import Integer, only: [is_odd: 1]
  defmodule Prime do
    defstruct value: 2
    def next(prime \\ %__MODULE__{value: 2})
    def next(%__MODULE__{value: 2}), do: %__MODULE__{value: 3}
    def next(%__MODULE__{value: n} = prime) do
      if is_prime(n + 2),
        do: %{prime | value: n + 2},
        else: next(%{prime | value: n + 2})
    end
    def first(1), do: 2
    def first(2), do: 2
    def first(3), do: 3
    def first(n) when is_odd(n), do: if is_prime(n), do: n, else: first(n + 2)
    def first(n), do: first(n + 1)

    def is_prime(n)
    def is_prime(n) when n < 2, do: false
    def is_prime(2), do: true
    def is_prime(3), do: true
    def is_prime(n) when 3 < n,
      do: if rem(n, 2) == 0, do: false, else: is_prime(n, 3)
    defp is_prime(n, i) when i * i <= n,
      do: if rem(n, i) == 0, do: false, else: is_prime(n, i + 2)
    defp is_prime(_, _), do: true

    defimpl Enumerable do
      def count(_), do: {:error, __MODULE__}
      def member?(_, _), do: {:error, __MODULE__}
      def slice(_), do: {:error, __MODULE__}
      def reduce(_prime, {:halt, acc}, _fun), do: {:halted, acc}
      def reduce(prime, {:suspend, acc}, fun),
        do: {:suspended, acc, &reduce(prime, &1, fun)}
      def reduce(%{value: v} = prime, {:cont, acc}, fun),
       do: reduce(Prime.next(prime), fun.(v, acc), fun)
    end
  end

  defp r_to_i, do: IO.read(:line) |> String.trim() |> String.to_integer()

  def main do
    IO.puts solve(r_to_i(), r_to_i())
  end

  def solve(k, n) do
    %Prime{value: Prime.first(k)}
    |> Enum.reduce_while({%{}, nil, nil}, fn
      prime, acc when n < prime ->
        {:halt, acc}
      prime, {memo, nil, max} ->
        {:cont, {Map.put(memo, prime, MapSet.new([frank_hash(prime)])), [prime], max}}
      prime, {memo, start_with, max} ->
        hashed_value = frank_hash(prime)
        memo = Map.put(memo, prime, MapSet.new([hashed_value]))
        {memo, max, complete} = start_with
        |> Enum.reduce({memo, max, []}, fn target, {memo, max, complete} ->
          if MapSet.member?(memo[target], hashed_value) do
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target, [max | complete]}
            else
              nil ->
                {memo, target, complete}
              _ ->
                {memo, max, [target | complete]}
            end
          else
            {Map.put(memo, target, MapSet.put(memo[target], hashed_value)), max, complete}
          end
        end)
        {
          :cont,
          {
            Enum.reduce(complete, memo, fn
              v, memo when v == max -> memo
              v, memo -> Map.delete(memo, v)
            end),
            Enum.reject([prime | start_with], fn v -> v in complete end),
            max
          }
        }
    end)
    |> (fn {memo, start_with, max} ->
        start_with
        |> Enum.reduce({memo, max}, fn
          target, {memo, max} ->
            with max when not is_nil(max) <- max,
              true <- MapSet.size(memo[max]) <= MapSet.size(memo[target]),
              true <- max < target do
              {memo, target}
            else
              nil ->
                {memo, target}
              _ ->
                {memo, max}
            end
        end)
        |> elem(1)
    end).()
  end

  defp frank_hash(n) when n < 10, do: n
  defp frank_hash(n), do: n |> Integer.digits() |> Enum.sum() |> frank_hash()
end
"""