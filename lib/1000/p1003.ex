defmodule P1003 do
  @moduledoc """
  ## Examples

    iex> P1003.solve(8)
    "No"

    iex> P1003.solve(6)
    "Yes"

    iex> P1003.solve(65536)
    "No"

  """

  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    n |> solve() |> IO.puts()
  end

  def solve(n) when rem(n, 6) == 0, do: "Yes"
  def solve(_), do: "No" 
end