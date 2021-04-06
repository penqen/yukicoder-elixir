defmodule Util do
  def combination(_, 0), do: [[]]
  def combination([], _), do: []
  def combination([x | xs], n) do
    for(y <- combination(xs, n - 1), do: [x | y]) ++ combination(xs, n)
  end

  def permutation(_, 0), do: [[]]
  def permutation(list, n) do
    for x <- list, rest <- permutation(list -- [x], n - 1), do: [x | rest]
  end
end