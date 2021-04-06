defmodule Practice1131 do
  @moduledoc """
  ## Examples

    iex> Practice1131.solve(5, [10, 40, 50, 30, 90])
    [33, 48, 53, 43, 73]

  """
  def solve(n, xn) when 1 <= n and 1 <= 100_000 and length(xn) == n do
    a = xn |> Enum.reduce(0.0, &(&1/n + &2))
    xn |> Enum.map(&(floor(50 - (a - &1) / 2)))
  end

  def solve(_, _), do: :error
end