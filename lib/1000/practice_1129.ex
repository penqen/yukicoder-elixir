defmodule Practice1129 do
  @moduledoc """
  # Examples
    iex> Practice1129.solve(688, 0, 1518, 0)
    "tRue"

    iex> Practice1129.solve(4000, 1, 4000, 2)
    "null"
  """
  def solve(a, _b, c, _d) when a < c, do: "tRue"
  def solve(a, _b, c, _d) when c < a, do: "null"
  def solve(_a, b, _c, d) when b == d, do: "Draw" 
  def solve(_a, b, _c, d), do: fight(b, d)

  def fight(0, 1), do: "null"
  def fight(0, 2), do: "tRue"
  def fight(1, 0), do: "tRue"
  def fight(1, 2), do: "null"
  def fight(2, 0), do: "null"
  def fight(2, 1), do: "tRue"

end