defmodule Practice1249 do
  @moduledoc """
  ## Examples

    iex> Practice1249.solve(3, 5, 8)
    "Correct"

    iex> Practice1249.solve(4, 1, 7)
    "Incorrect"

    iex> Practice1249.solve(100, 100, 200)
    "Correct"
  """
  def solve(a, b, c) when 0 <= a and b <= 100 and 0 <= c and c <= 200 do
    if a + b == c do
      "Correct"
    else
      "Incorrect"
    end
  end

  def solve(_a, _b, _c), do: "Incorrect"
end