defmodule Practice1070 do
  @moduledoc """
  ## Examples
    iex> Practice1070.solve("1234")
    3

    iex> Practice1070.solve("1010")
    1

    iex> Practice1070.solve("222")
    2

  """ 
  def solve(n) do
    n |> String.replace("0", "") |> String.length() |> Kernel.-(1)
  end
end