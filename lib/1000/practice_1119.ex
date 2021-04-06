defmodule Practice1119 do
  @moduledoc """
  ## Examples

    iex> Practice1119.solve(1, 2, 3)
    "Yes"

    iex> Practice1119.solve(5, 2, 5)
    "No"

  """ 
  def solve(x, y, z)
  def solve(x, _y, _z) when rem(x, 3) == 0, do: "Yes"
  def solve(_x, y, _z) when rem(y, 3) == 0, do: "Yes"
  def solve(_x, _y, z) when rem(z, 3) == 0, do: "Yes"
  def solve(_, _, _), do: "No"
end