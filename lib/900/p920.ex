defmodule P920 do
  @moduledoc """
  ## Examples

    iex> P920.solve(3, 4, 5)
    6

    iex> P920.solve(1, 5, 8)
    7

    iex> P920.solve(1, 5, 9)
    7

  """

  def main do
    [x, y, z] = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(x, y, z) |> IO.puts()
  end

  def solve(x, y, z) when x + z <= y, do: x + z
  def solve(x, y, z) when y + z <= x, do: y + z
  def solve(x, y, z), do: floor((x + y + z) / 2)
end