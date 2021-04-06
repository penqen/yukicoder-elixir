defmodule Practice1108 do
  @moduledoc """
  ## Examples
    iex> Practice1108.solve(5, 1, [2, 0, -1, -5, -3])  
    [3, 1, 0, -4, -2]

    iex> Practice1108.solve(7, -12, [2, 4, 6, 9, 11, 14, 9])  
    [-10, -8, -6, -3, -1, 2, -3]

    iex> Practice1108.solve(1, 100, [100])  
    [200]

  """
  def solve(_n, h, tn) do
    tn |> Enum.map(&(&1 + h))
  end  

end