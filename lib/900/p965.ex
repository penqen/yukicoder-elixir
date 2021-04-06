defmodule P965 do
  @moduledoc """
  ## Examples

    iex> P965.solve(3, 5, 1)
    2

  """

  def main do
    [a, b, c] = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(a, b, c) |> IO.puts()
  end

  def solve(a, b, c) do
    [abs(b - a), abs(b - c), abs(a - c)] |> Enum.min()
  end
end