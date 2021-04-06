defmodule P926 do
  @moduledoc """
  ## Examples

    iex> P926.solve(365, 7, 2)
    104.28571428

    iex> P926.solve(10, 20, 20)
    10.00000000

    iex> P926.solve(1000, 7, 0)
    0.0000000

  """
  def main do
    [a, b, c] = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(a, b, c) |> IO.puts()
  end

  def solve(a, b, c) do
    Float.floor(a / b * c, 8)
  end
end