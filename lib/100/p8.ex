defmodule P8 do
  @moduledoc """
    (i) N - 1 < K であれば、先手が N を言えば勝てる。
    (ii) N > K のとき、 
      先手と後手合わせて, K + 1を維持すると、さいごに必ず、 N mod K + 1 の余りがでる。
      先手が必勝するためには、 N - 1 mod K + 1 の余を初手で言い、そのあと K + 1を維持すること。
      N - 1 mod K + 1 == 0 の時、後手必勝となる。

  # Examples

    iex> P8.solve(21, 3)
    false

    iex> P8.solve(12, 5)
    true

    iex> P8.solve(5, 10)
    true

    iex> P8.solve(40, 6)
    true

    iex> P8.solve(100, 8)
    false
  """
  def main do
    p = IO.read(:line) |> String.trim() |> String.to_integer()
    for _ <- 1..p do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end
    |> Enum.each(fn [n, k] ->
      solve(n, k)
      |> if do
        "Win"
      else
        "Lose"
      end
      |> IO.puts
    end)
  end

  def solve(n, k), do: Integer.mod(n - 1, k + 1) != 0 
end

"""
defmodule Main do
  def main do
    p = IO.read(:line) |> String.trim() |> String.to_integer()
    for _ <- 1..p do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1) |> solve() |> if(do: "Win", else: "Lose") |> IO.puts()
    end
  end

  def solve([n, k]), do: Integer.mod(n - 1, k + 1) != 0 
end
"""