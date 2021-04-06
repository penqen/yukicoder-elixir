defmodule P975 do
  @moduledoc """
  ## Examples
  
    iex> P975.solve(114, 5, 8, [1, 3, 4, 9, 12], [2, 3, 11, 18, 114, 514, 364, 1919])
    "MaxValu"

    iex> P975.solve(2525, 1, 1, [2525], [2525])
    "MrMaxValu"

  """
  def main do
    [x, n, m] = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    bm = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(x, n, m, an, bm) |> IO.puts() 
  end

  def solve(x, _n, _m, an, bm) do
    case {Enum.find(an, &(&1 == x)), Enum.find(bm, &(&1 == x))} do
      {^x, ^x} -> "MrMaxValu"
      {^x, nil} -> "MrMax"
      {nil, ^x} -> "MaxValu"
      _ -> -1
    end
  end
end