defmodule P998 do
  @moduledoc """
  ## Examples

    iex> P998.solve([3, 1, 2, 4])
    "Yes"

    iex> P998.solve([0, 2, 2, 4])
    "No"

  """

  def main do
    IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1) |> solve() |> IO.puts()
  end

  def solve(list), do: list |> Enum.sort() |> sequential?()

  def sequential?([_]), do: "Yes"
  def sequential?([x | [y | _] = tail]) when x + 1 == y, do: sequential?(tail)
  def sequential?(_), do: "No"
end