defmodule P11 do
  @moduledoc """

  iex> P11.solve(2, 5, 1, [[1, 1]])
  5

  iex> P11.solve(4, 13, 3, [[1, 1], [2, 1], [2, 5]])
  27

  iex> P11.solve(4, 13, 4, [[1, 5], [2, 6], [3, 7], [4, 8]])
  48

  iex> P11.solve(3, 2, 2, [[1, 1], [2, 1]])
  3

  """
  def main do
    w = IO.read(:line) |> String.trim() |> String.to_integer()
    h = IO.read(:line) |> String.trim() |> String.to_integer()
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    sk = for _ <- 0..(n - 1) do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end
    [w, h, n] |> IO.inspect
    sk |> IO.inspect
  end

  def solve(w, h, n, sk) do
    n
  end
end
"""
defmodule Main do
  def main do
  end
end
"""