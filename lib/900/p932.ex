defmodule P932 do
  @moduledoc """
  ## Examples

    iex> P932.solve(["AC", "AC", "AC", "AC", "AC"])
    "Done!"

    iex> P932.solve(["AC", "AC", "AC", "AC", "AC", "WA", "AC"])
    "Failed..."

    iex> P932.solve(["AC", "AC", "AC", "TLE", "TLE", "TLE", "TLE", "MLE"])
    "Failed..."

  """

  def main do
    IO.read(:line) |> String.trim() |> String.split(",") |> solve() |> IO.puts()
  end

  def solve(s) do
    s
    |> Enum.filter(&(&1 != "AC"))
    |> length()
    |> case do
      0 -> "Done!"
      _ -> "Failed..."
    end
  end
end