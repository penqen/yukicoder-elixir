defmodule Practice1107 do
  @moduledoc """
  ## Examples
    iex> Practice1107.solve([1, 2, 3, 2])
    "YES"

    iex> Practice1107.solve([2, 4, 7, 9])
    "NO"

    iex> Practice1107.solve([4, 4, 7, 2])
    "NO"
  """
  def solve([a1, a2, a3, a4]) when a1 < a2 and a4 < a3, do: "YES"
  def solve(_), do: "NO"
end