defmodule P993 do
  @moduledoc """
  ## Examples
  
    iex> P993.solve("aoaoaoi")
    "kikikii"

    iex> P993.solve("alohaoe")
    "alohkie"

    iex> P993.solve("aokisan")
    "kikisan"
  
  """

  def main do
    IO.read(:line) |> String.trim() |> solve() |> IO.puts()
  end

  def solve(s), do: String.replace(s, "ao", "ki")
end