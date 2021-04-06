defmodule P5 do
  @moduledoc """
  ## Examples

    iex> P5.solve(16, [10, 5, 7])
    2

    iex> P5.solve(100, [14, 85, 77, 26, 50, 45, 66, 79, 10, 3])
    5

  """

  def main do
    l = IO.read(:line) |> String.trim() |> String.to_integer()
    IO.read(:line)
    wn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(l, wn) |> IO.puts()
  end

  def solve(l, wn) do
    wn
    |> Enum.sort()
    |> Enum.reduce_while({0, 0}, fn w, {sum, count} = acc ->
      if l < sum + w, do: {:halt, acc}, else: {:cont, {sum + w, count + 1}}
    end)
    |> elem(1)
  end
end

"""
defmodule Main do
  def main do
    l = IO.read(:line) |> String.trim() |> String.to_integer()
    IO.read(:line)
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
    |> Enum.reduce_while({0, 0}, fn w, {sum, count} = acc ->
      if l < sum + w, do: {:halt, acc}, else: {:cont, {sum + w, count + 1}}
    end)
    |> elem(1)
    |> IO.puts()
  end
end
"""