defmodule P7 do
  @moduledoc """
  2 <= N <= 10_000

  Grundy数を、DPを使って求める感じ？

  - Nを含むそれ以下の素数のどれかで減算し、Ndとする。
  - Nd in [0, 1] となったらそのプレイヤーの負け。
  - N = Ndとし、相手プレイヤーも同様の操作を行い、繰り返す。

  - (N - 2) 以下の素数 p を選んで、 相手に N = N - p を渡す
  - DPを、エラトステスの篩を使って、小さい順に埋めて、勝敗表を構築する。

  漸化式
    dp[0] = false
    dp[1] = false
    dp[2] = false
    dp[3] = false
    dp[4] = or(not dp[n - 3], not dp[n - 2])
    dp[5] = or(not dp[n - 3], not dp[n - 2))
    dp[n] = or(not dp[n - p]) in p < N


  # Examples
    iex> P7.solve(5)
    true

    iex> P7.solve(12)
    false
  """

  defmodule Prime do
    defstruct value: 2
    def next(prime \\ %__MODULE__{value: 2})
    def next(%__MODULE__{value: 2}), do: %__MODULE__{value: 3}
    def next(%__MODULE__{value: n} = prime) do
      if is_prime(n + 2),
        do: %{prime | value: n + 2},
        else: next(%{prime | value: n + 2})
    end

    def is_prime(n)
    def is_prime(n) when n < 2, do: false
    def is_prime(n) when n in [2, 3], do: true
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

  def main do
    IO.read(:line)
    |> String.trim()
    |> String.to_integer()
    |> solve()
    |> if do
      "Win"
    else
      "Lose"
    end
    |> IO.puts() 
  end

  @doc """
  dp[i] : false (0 <= i <= 3)
  dp[i] : not dp[i - p] (p < i - 2)
  """
  def solve(n) do
    primes = Enum.reduce_while(%Prime{}, [], fn
      prime, primes when n < prime ->
        {:halt, Enum.reverse(primes)}
      prime, primes ->
        {:cont, [prime | primes]}
    end)

    memo = 2..n
    |> Enum.reduce(%{1 => false}, fn
      i, memo ->
        flag = primes
        |> Enum.reduce_while(false, fn
          _p, true -> {:halt, true}
          p, flag when i < p -> {:halt, flag}
          p, flag when i - p < 2 -> {:halt, flag}
          p, _flag ->
            {:cont, not(memo[i - p])}
        end)
        Map.put(memo, i, flag)
    end)

    memo[n]
  end

  @doc """
  予め、素数を計算している。
  nまで昇順に勝敗をメモ化して求める方法。
  `solve_full`において、必勝かどうか探索する処理の冗長部分を改善
  """
  def solve_light(n) do
    primes = Enum.reduce_while(%Prime{}, [], fn
      prime, primes when n < prime ->
        {:halt, Enum.reverse(primes)}
      prime, primes ->
        {:cont, [prime | primes]}
    end)

    memo = 2..n
    |> Enum.reduce(%{1 => false}, fn
      i, memo ->
        flag = primes
        |> Enum.reduce_while(false, fn
          _p, true -> {:halt, true}
          p, flag when i < p -> {:halt, flag}
          p, flag when i - p < 2 -> {:halt, flag}
          p, _ ->
            {:cont, not(memo[i - p])}
        end)
        Map.put(memo, i, flag)
    end)

    memo[n]
  end

  @doc """
  予め、素数を計算している。
  nまで昇順に勝敗をメモ化して求める方法。
  nまでの全てを計算するため少し遅いかも。
  """
  def solve_full(n) do
    primes = Enum.reduce_while(%Prime{}, [], fn
      prime, primes when n < prime ->
        {:halt, Enum.reverse(primes)}
      prime, primes ->
        {:cont, [prime | primes]}
    end)

    memo = 2..n
    |> Enum.reduce(%{1 => false}, fn
      i, memo ->
        flag = primes
        |> Enum.reduce_while(false, fn
          p, flag when i < p -> {:halt, flag}
          p, flag when i - p < 2 -> {:halt, flag}
          p, flag ->
            {:cont, flag || not(memo[i - p])}
        end)
        Map.put(memo, i, flag)
    end)

    memo[n]
  end
end

"""
defmodule Main do
  defmodule Prime do
    defstruct value: 2
    def next(prime \\ %__MODULE__{value: 2})
    def next(%__MODULE__{value: 2}), do: %__MODULE__{value: 3}
    def next(%__MODULE__{value: n} = prime) do
      if is_prime(n + 2),
        do: %{prime | value: n + 2},
        else: next(%{prime | value: n + 2})
    end

    def is_prime(n)
    def is_prime(n) when n < 2, do: false
    def is_prime(n) when n in [2, 3], do: true
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

  def main do
    IO.read(:line) |> String.trim() |> String.to_integer() |> solve()
    |> if do
      "Win"
    else
      "Lose"
    end
    |> IO.puts() 
  end

  def solve(n) do
    primes = Enum.reduce_while(%Prime{}, [], fn
      prime, primes when n < prime ->
        {:halt, Enum.reverse(primes)}
      prime, primes ->
        {:cont, [prime | primes]}
    end)

    memo = 2..n
    |> Enum.reduce(%{1 => false}, fn
      i, memo ->
        flag = primes
        |> Enum.reduce_while(false, fn
          _p, true -> {:halt, true}
          p, flag when i < p -> {:halt, flag}
          p, flag when i - p < 2 -> {:halt, flag}
          p, _flag ->
            {:cont, not(memo[i - p])}
        end)
        Map.put(memo, i, flag)
    end)

    memo[n]
  end
end
"""