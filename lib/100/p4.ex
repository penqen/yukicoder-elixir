defmodule P4 do
  @moduledoc """
  ## Examples
  """ 

  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    wn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)

    solve(n, wn) |> IO.puts()
  end

  @doc """
  ## Examples
    iex> P4.solve(3, [1, 2, 3])
    :possible

    iex> P4.solve(5, [1, 2, 3, 4, 5])
    :impossible

    iex> P4.solve(15, [62, 8, 90, 2, 24, 62, 38, 64, 76, 60, 30, 76, 80, 74, 72])
    :impossible

    iex> P4.solve(10, [88, 15, 15, 82, 19, 17, 35, 86, 40, 33])
    :possible

  """
  def solve(n, wn) do
    with sum <- Enum.sum(wn),
      0 <- rem(sum, 2) do
        max = round(sum / 2)

        dp = %{ 0 => 0..max |> Enum.reduce(%{}, &Map.put(&2, &1, 0))}

        wn
        |> Enum.with_index()
        |> Enum.reduce(dp, fn {w, i}, dp ->
          dp_i = 0..max
          |> Enum.reduce(dp[i], fn j, acc ->
            dp_j = if w <= j do
              max(dp[i][j - w] + w, dp[i][j])
            else
              dp[i][j]
            end
            Map.put(acc, j, dp_j)
          end)
          Map.put(dp, i + 1, dp_i)
        end)
        |> (fn dp ->
          dp[n][max]
        end).()
        |> Kernel.==(max)
        |> if do
          :possible
        else
          :impossible
        end
    else
      _ ->
        :impossible
    end
  end
"""
DP Array type
  def solve(_n, wn) do
    with sum <- Enum.sum(wn),
      0 <- rem(sum, 2) do
        max = round(sum / 2)
        wn
        |> Enum.sort()
        |> Enum.reduce(nil, fn
          w, nil ->
            0..max
            |> Enum.with_index()
            |> Enum.map(fn
              {_, j} when j < w -> 0
              {_, _j} -> w
            end)
          w, acc ->
            acc
            |> Enum.with_index()
            |> Enum.map(fn
              {v, j} when j < w -> v
              {v, j} ->
                with choice when v <= choice <- Enum.at(acc, j - w) + w do
                  choice
                else
                  _ -> v
                end
            end)
        end)
        |> List.last()
        |> Kernel.==(max)
        |> if do
          :possible
        else
          :impossible
        end
    else
      _ ->
        :impossible
    end
  end
"""
end

"""
defmodule Main do
  def main do
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    wn = IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    solve(n, wn) |> IO.puts()
  end

  def solve(n, wn) do
    with sum <- Enum.sum(wn),
      0 <- rem(sum, 2) do
        max = round(sum / 2)
        dp = %{ 0 => 0..max |> Enum.reduce(%{}, &Map.put(&2, &1, 0))}
        wn
        |> Enum.with_index()
        |> Enum.reduce(dp, fn {w, i}, dp ->
          dp_i = 0..max
          |> Enum.reduce(dp[i], fn j, acc ->
            dp_j = if w <= j do
              max(dp[i][j - w] + w, dp[i][j])
            else
              dp[i][j]
            end
            Map.put(acc, j, dp_j)
          end)
          Map.put(dp, i + 1, dp_i)
        end)
        |> (fn dp ->
          dp[n][max]
        end).()
        |> Kernel.==(max)
        |> if do
          :possible
        else
          :impossible
        end
    else
      _ ->
        :impossible
    end
  end
end
"""