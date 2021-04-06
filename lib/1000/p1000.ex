defmodule P1000 do
  @moduledoc """
  :timer.tc(&Main.main/0)

  Query
    A(x, y) : A_x + y
    B(x, y) : B_i + A_i (x <= i <= y) 

  # Examples
    iex> an = [9, 8, 1, 9, 6, 10, 8]
    ...>      |> Enum.with_index() |> Enum.reduce(%{}, &(Map.put(&2, elem(&1, 1), elem(&1, 0))))
    ...> P1000.solve(7, 3, an, [["B", 2, 5], ["A", 7, 9], ["B", 4, 7]])
    [0, 8, 1, 18, 12, 10, 17]

    iex> {n, q} = {10, 10}
    ...> an = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
    ...>      |> Enum.with_index() |> Enum.reduce(%{}, &(Map.put(&2, elem(&1, 1), elem(&1, 0))))
    ...> queries = [
    ...>   ["A", 2, 7],
    ...>   ["A", 5, 9],
    ...>   ["B", 1, 4],
    ...>   ["B", 6, 10],
    ...>   ["A", 10, 3],
    ...>   ["B", 1, 2],
    ...>   ["A", 8, 3],
    ...>   ["B", 4, 9],
    ...>   ["A", 6, 2],
    ...>   ["B", 1, 10]
    ...> ]
    ...> P1000.solve(n, q, an, queries)
    [3, 33, 2, 15, 36, 8, 18, 21, 9, 13]
  """
  def main do
    [n, q] = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.with_index() |> Enum.reduce(%{}, &(Map.put(&2, elem(&1, 1), String.to_integer(elem(&1, 0)))))
    queries = for _ <- 0..(q-1) do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(fn
        v when v in ["A", "B"] -> v
        v -> String.to_integer(v)
      end)
    end
    solve(n, q, an, queries) |> Enum.join(" ") |> IO.puts()
  end

  def solve(n, _q, an, queries) do
    {_, bn} = Enum.reduce(queries, {an, Enum.reduce(0..(n-1), %{}, &(Map.put(&2, &1, 0)))}, fn
      ["A", x, y], {an, bn} ->
        {Map.put(an, x - 1, an[x - 1] + y), bn}
      ["B", x, y], {an, bn} ->
        {an, Enum.reduce((x - 1)..(y - 1), bn, &(Map.put(&2, &1, bn[&1] + an[&1])))}
    end)

    (n-1)..0 |> Enum.reduce([], fn i, acc -> [bn[i] | acc] end)
  end
end
"""
defmodule Main do
  def main do
    [n, q] = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    an = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.with_index() |> Enum.reduce(%{}, &(Map.put(&2, elem(&1, 1), String.to_integer(elem(&1, 0)))))
    queries = for _ <- 0..(q-1) do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(fn
        v when v in ["A", "B"] -> v
        v -> String.to_integer(v)
      end)
    end
    solve(n, q, an, queries) |> Enum.join(" ") |> IO.puts()
  end

  def solve(n, _q, an, queries) do
    {_, bn} = Enum.reduce(queries, {an, Enum.reduce(0..(n-1), %{}, &(Map.put(&2, &1, 0)))}, fn
      ["A", x, y], {an, bn} -> {Map.put(an, x - 1, an[x - 1] + y), bn}
      ["B", x, y], {an, bn} -> {an, Enum.reduce((x - 1)..(y - 1), bn, &(Map.put(&2, &1, bn[&1] + an[&1])))}
    end)
    (n-1)..0 |> Enum.reduce([], fn i, acc -> [bn[i] | acc] end)
  end
end
"""