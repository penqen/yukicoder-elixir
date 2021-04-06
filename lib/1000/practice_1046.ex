defmodule Practice1046 do
  @moduledoc """
  ## Examples
    iex> Practice1046.solve(3, 2, [1, 3, 2])
    5

    iex> Practice1046.solve(4, 3, [1, 2, -1, -2])
    3

    iex> Practice1046.solve(5, 5, [0, 0, 0, 0, 0])
    0

  """ 
  def solve(n, k, an) when 1 <= k and k <= n and n <= 100 do
    an = an |> Enum.sort(&(&1 > &2))
    
    an
    |> Enum.reject(&(&1 < 1))
    |> (fn
      [] ->
        [t | _] = an
        [t]
      x ->
        x
    end).()
    |> Stream.take(k)
    |> Enum.reduce(0, &(&1 + &2))
  end
end