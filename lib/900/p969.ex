defmodule P969 do
  @moduledoc """
  ## Examples

    iex> P969.solve(0)
    "Yes"

    iex> P969.solve(7)
    "No"

  """
  def main do
    IO.read(:line) |> String.trim() |> String.to_integer() |> solve() |> IO.puts()
  end

  def solve(0), do: "Yes"
  def solve(4), do: "Yes"
  def solve(10), do: "Yes"
  def solve(_), do: "No"
end