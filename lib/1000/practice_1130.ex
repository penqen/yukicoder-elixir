defmodule Practice1130 do
  @moduledoc """
  ## Examples

    iex> Practice1130.solve(4,5, [[9,0,2,3,8],[1,1,4,5,1],[9,8,6,4,0],[1,9,7,0,9]])
    [[0,0,0,1,1], [1,1,2,3,4], [4,5,6,7,8], [8,9,9,9,9]]

    iex> Practice1130.solve(5,3, [[1,1,1], [1,1,2], [2,2,2], [2,3,3], [3,3,3]])
    [[1,1,1], [1,1,2], [2,2,2], [2,3,3], [3,3,3]]
  """
  def solve(_h, w, hw) do
    hw |> List.flatten() |> Enum.sort() |> Enum.chunk_every(w)
  end
end