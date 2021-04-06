defmodule Practice1205 do
  @moduledoc """
  ## Examples

    iex> Practice1205.solve(3, 2, [[1, 0], [4, 2]])
    "Yes"

    iex> Practice1205.solve(2, 1, [[0, 1]])
    "No"

  """
  def solve(n, m, matrix) when 1 <= n
    and 0 <= m and m <= 100_000
    and is_list(matrix)
  do
    matrix
    |> Enum.reduce({true, {0, 0}}, fn
      [ti, pi], {true, {ct, cp}} ->
        dt = ti - ct
        dp = abs(cp - pi)
        if dp <= dt and pi < n do
          {true, {ti, pi}}
        else
          false
        end
      _, false ->
        false
    end)
    |> (fn
      false ->
        "No"
      {true, _} ->
        "Yes"
    end).()
  end

  def solve(_n, _m, _matrix), do: "No"
end