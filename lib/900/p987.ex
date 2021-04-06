defmodule P987 do
  @moduledoc """
  ## Examples

    iex> P987.solve(3, 4, "+", [5, 12, 6, 13], [8, 27, 3])
    [
      [13, 20, 14, 21],
      [32, 39, 33, 40],
      [8, 15, 9, 16],
    ]

    iex> P987.solve(3, 4, "*", [5, 12, 6, 13], [8, 27, 3])
    [
      [40, 96, 48, 104],
      [135, 324, 162, 351],
      [15, 36, 18, 39]
    ]

  """
  def main do
    [n, m] = IO.read(:line) |> String.trim() |> String.split() |> Enum.map(&String.to_integer/1)
    [op, bm] = IO.read(:line) |> String.trim() |> String.split() |> (fn
      [op | tail] -> [op, Enum.map(tail, &String.to_integer/1)]
    end).()
    an = for _ <- 1..n, do: IO.read(:line) |> String.trim() |> String.to_integer()
    solve(m, n, op, bm, an) |> Enum.map_join("\n", &(Enum.join(&1, " "))) |> IO.puts()
  end

  def solve(_m, _n, op, bm, an) do
    Enum.map(an, fn ai ->
      Enum.map(bm, fn bj ->
        case op do
          "+" -> ai + bj
          "*" -> ai * bj
        end
      end)
    end)
  end
end