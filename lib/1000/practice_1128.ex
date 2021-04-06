defmodule Practice1128 do
  @moduledoc """
  ## Examples

    iex> Practice1128.solve(2)
    3

    iex> Practice1128.solve(11)
    11

  """
  def solve(n) when 0 <= n and n <= 100_000_000 do
    if rem(n, 2) == 0, do: n + 1, else: n
  end
end