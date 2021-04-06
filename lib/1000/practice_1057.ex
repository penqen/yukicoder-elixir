defmodule Practice1057 do
  @moduledoc """
  ## Examples
    iex> Practice1057.solve([4, 3])
    6

    iex> Practice1057.solve([3, 1])
    2
  """
  def solve([a, b]) when a == b, do: a + b - 1
  def solve([a, b]) when a < b, do: a * 2
  def solve([a, b]) when b < a, do: b * 2
end