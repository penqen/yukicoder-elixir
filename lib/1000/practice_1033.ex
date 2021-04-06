defmodule Practice1033 do
  @moduledoc """
  ## Examples

    iex> Practice1033.solve(2, 2)
    1.0

    iex> Practice1033.solve(4, 3)
    2.0

  """
  def solve(n, k) when 1 <= n and n <= 100_000
    and 1 <= k and k <= 100_000
  do
    0..n
    |> Enum.reduce({0, 0}, fn ni, {sum, count} ->
      ki = 0..k |> Enum.count
      {sum + ni * ki, count + ki}
    end)
    |> (fn {sum, count} ->
      sum / count
    end).()
  end
end