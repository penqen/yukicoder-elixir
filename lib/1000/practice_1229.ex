defmodule Practice1229 do
  @moduledoc """
  ## Examples
  
    iex> Practice1229.solve(0)
    1

    iex> Practice1229.solve(5)
    1

    iex> Practice1229.solve(20)
    4

    iex> Practice1229.solve(100)
    55

  """
  def solve(n) when 0 <= n and n <= 100 do
    dg = div(n, 7)

    0..dg
    |> Enum.map(&(&1 * 7))
    |> Enum.reduce(0, fn g, count ->
      dt = div(n - g, 5)

      0..dt
      |> Enum.map(&(&1 * 5))
      |> Enum.reduce(count, fn t, count ->
        pg = div(n - g - t, 3) * 3
        if (g + t + pg) == n, do: count + 1, else: count
      end)
    end)
  end

  def solve(_), do: :error
end