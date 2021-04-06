defmodule Practice1040 do
  @moduledoc """
  ## Examples

    iex> Practice1040.solve(90)
    "Yes"

    iex> Practice1040.solve(180)
    "No"

    iex> Practice1040.solve(630)
    "Yes"
  """
  def solve(n) when 1 <= n and n <= 1_000 do
    if rem(n, 180) == 90 do
      "Yes"
    else
      "No"
    end
  end
end