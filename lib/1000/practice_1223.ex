defmodule Practice1223 do
  @moduledoc """
  # Examples

    iex> Practice1223.solve(8, 3, 4)
    Yes

    iex> Practice1223.solve(-10, 4, 2)
    No

    iex> Practice1223.solve(1000000000,999999999,1)
    No

  """
  def solve(n, k, t) when - 1_000_000_000 <= n and n <= 1_000_000_000
    and n not in [2004, 2006]
    and 1 <= k and k <= 1_000_000_000
    and 1 <= t and t <= 1_000_000_000
  do
    if abs(n) <= k * t do
      "Yes"
    else
      "No"
    end
  end

  def solve(_n, _k, _t), do: "No"
end