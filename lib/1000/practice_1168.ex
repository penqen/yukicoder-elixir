defmodule Practice1168 do
  @moduledoc """
  ## Examples
  
    iex> Practice1168.solve(753)
    6

    iex> Practice1168.solve(123456789)
    9

  """
  def solve(n), do: solve(n, 1)

  def solve(n, _) when n < 10, do: n
  def solve(n, 100), do: n
  def solve(n, i) when 1 <= n and n <= 1_000_000_000 do
    num_of_digits = n |> to_string() |> String.length()
    n |> a_i(num_of_digits) |> solve(i + 1)
  end
  def solve(_, _), do: :error

  def a_i(n, 0), do: n
  def a_i(n, num_of_digits) do
    base = :math.pow(10, num_of_digits) |> round()
    div(n, base) + a_i(rem(n, base), num_of_digits - 1)
  end

end