defmodule P2 do
  @moduledoc """
  ## Examples
  """
  use Bitwise, only_operators: true

  defmodule Factorization do
    defstruct value: 2

    def next(factor \\ %__MODULE__{value: 2})
    def next(%__MODULE__{value: 2}), do: %__MODULE__{value: 3}
    def next(%__MODULE__{value: n}) do
      if is_prime(n + 2) do
        %__MODULE__{value: n + 2}
      else
        next(%__MODULE__{value: n + 2})
      end
    end

    @doc """
    素数を判定する。

    # Examples

      iex> P2.is_prime(1)
      false

      iex> [2, 3, 5, 7, 11, 13, 17, 19]
      ...> |> Enum.map(&P2.is_prime/1)
      [true, true, true, true, true, true, true, true]

      iex> P2.is_prime(4)
      false

      iex> P2.is_prime(24)
      false

      iex> P2.is_prime(58)
      false

    """
    def is_prime(n)
    def is_prime(n) when n < 2, do: false
    def is_prime(2), do: true
    def is_prime(3), do: true
    def is_prime(n) when 3 < n do
      if rem(n, 2) == 0 do
        false
      else
        is_prime(n, 3)
      end
    end
    defp is_prime(n, i) when i * i <= n do
      if rem(n, i) == 0 do
        false
      else
        is_prime(n, i + 2)
      end
    end
    defp is_prime(_, _), do: true

    def to_list(n, factor \\ %Factorization{}, combinations \\ [])
    def to_list(1, _, combinations), do: combinations
    def to_list(n, %{value: prime} = factor, combinations) do
      if Factorization.is_prime(n) do
        [{n, 1} | combinations]
      else
        if rem(n, prime) == 0 do
          {n0, base} = to_exponent(n, prime)
          to_list(n0, Factorization.next(factor), [{prime, base} | combinations])
        else
          to_list(n, Factorization.next(factor), combinations)
        end
      end
    end

    defp to_exponent(n, factor, count \\ 0)
    defp to_exponent(n, factor, count) do
      if rem(n, factor) == 0 do
        to_exponent(div(n, factor), factor, count + 1)
      else
        {n, count}
      end
    end
  end

  def main do
    IO.read(:line) |> String.trim() |> String.to_integer() |> solve() |> IO.puts()
  end

  @doc """
  素因数分解をして、その冪指数に対して、Nimゲームを行う.

  ## Examples

    iex> P2.solve(4)
    "Alice"
    
    iex> P2.solve(11)
    "Alice"
    
    iex> P2.solve(24)
    "Alice"
    
    iex> P2.solve(600)
    "Bob"

  """
  def solve(n) when 2 <= n and n <= 100_000_000 do
    n
    |> Factorization.to_list()
    |> Enum.reduce(nil, fn 
      {_prime_number, number}, nil ->
        number
      {_prime_number, number}, acc ->
        acc ^^^ number 
    end)
    |> Kernel.==(0)
    |> if do
      "Bob"
    else
      "Alice"
    end
  end
end

"""
defmodule Main do
  use Bitwise, only_operators: true

  defmodule Factorization do
    defstruct value: 2

    def next(factor \\ %__MODULE__{value: 2})
    def next(%__MODULE__{value: 2}), do: %__MODULE__{value: 3}
    def next(%__MODULE__{value: n}) do
      if is_prime(n + 2) do
        %__MODULE__{value: n + 2}
      else
        next(%__MODULE__{value: n + 2})
      end
    end

    def is_prime(n)
    def is_prime(n) when n < 2, do: false
    def is_prime(2), do: true
    def is_prime(3), do: true
    def is_prime(n) when 3 < n do
      if rem(n, 2) == 0 do
        false
      else
        is_prime(n, 3)
      end
    end
    defp is_prime(n, i) when i * i <= n do
      if rem(n, i) == 0 do
        false
      else
        is_prime(n, i + 2)
      end
    end
    defp is_prime(_, _), do: true

    def to_list(n, factor \\ %Factorization{}, combinations \\ [])
    def to_list(1, _, combinations), do: combinations
    def to_list(n, %{value: prime} = factor, combinations) do
      if Factorization.is_prime(n) do
        [{n, 1} | combinations]
      else
        if rem(n, prime) == 0 do
          {n0, base} = to_exponent(n, prime)
          to_list(n0, Factorization.next(factor), [{prime, base} | combinations])
        else
          to_list(n, Factorization.next(factor), combinations)
        end
      end
    end

    defp to_exponent(n, factor, count \\ 0)
    defp to_exponent(n, factor, count) do
      if rem(n, factor) == 0 do
        to_exponent(div(n, factor), factor, count + 1)
      else
        {n, count}
      end
    end
    end

  def main do
    IO.read(:line) |> String.trim() |> String.to_integer() |> solve() |> IO.puts()
  end

  def solve(n) when 2 <= n and n <= 100_000_000 do
    n
    |> Factorization.to_list()
    |> Enum.reduce(nil, fn 
      {_prime_number, number}, nil ->
        number
      {_prime_number, number}, acc ->
        acc ^^^ number 
    end)
    |> Kernel.==(0)
    |> if do
      "Bob"
    else
      "Alice"
    end
  end
end
"""