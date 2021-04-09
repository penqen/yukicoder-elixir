defmodule P11 do
  @moduledoc """
  - `W`: マーク (`1 <= W <= 1_000_000`)  
  - `H`: 番号 (`1 <= H <= 1_000_000`)  
  - `N`: 手札の枚数 (`1 <= N <= min(W * H, 100)`)  
  - `(Si, Ki)`: (i番目の手札のマーク,i番目の手札の数字)  

  定義: マッチ = マークまたは数字のどちらかが一致すること。

  出力: [手札のカード以外]のマッチするカードの枚数

  解法)

  - カードの総数は `W * H`
  - 手札のマーク`Si`及び数字`Ki`から重複を排除した総数をそれぞれ`Su`及び`Ku`とする
  - すると、マッチしないカードの総数は, `(W - Su) * (H - Ku)` となる。
  - そこから手札を考慮せずにマッチする総数を考えると、`W * H - (W - Su) * (H - Ku)`となる。
  - 最終的に求める値は、マッチする総数から手札を除いた値になる。
  - つまり、 `W * H - (W - Su) * (H - Ku) - N`
  - 後は式を展開するだけ

  ``` 
  ans = w * h - (w - su) * (h - ku) - n
      = w * h - (w * h - w * ku - su * h + su * ku) - n
      = w * ku + h * su - su * ku - n
  ```

  # Examples

  iex> P11.solve(2, 5, 1, [[1, 1]])
  5

  iex> P11.solve(4, 13, 3, [[1, 1], [2, 1], [2, 5]])
  27

  iex> P11.solve(4, 13, 4, [[1, 5], [2, 6], [3, 7], [4, 8]])
  48

  iex> P11.solve(3, 2, 2, [[1, 1], [2, 1]])
  3

  """
  def main do
    w = IO.read(:line) |> String.trim() |> String.to_integer()
    h = IO.read(:line) |> String.trim() |> String.to_integer()
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    sk = for _ <- 0..(n - 1) do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end
    solve(w, h, n, sk) |> IO.puts()
  end

  def solve(w, h, n, sk) do
    {s, k} = Enum.reduce(sk, {[], []}, fn [s, k], {sq, kq} -> {[s | sq], [k | kq]} end)
    s = s |> Enum.uniq() |> length()
    k = k |> Enum.uniq() |> length()
    w * k + s * h - s * k - n
  end
end

"""
defmodule Main do
  def main do
    w = IO.read(:line) |> String.trim() |> String.to_integer()
    h = IO.read(:line) |> String.trim() |> String.to_integer()
    n = IO.read(:line) |> String.trim() |> String.to_integer()
    {s, k} = for _ <- 0..(n - 1) do
      IO.read(:line) |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end
    |> Enum.reduce({[], []}, fn [s, k], {sq, kq} -> {[s | sq], [k | kq]} end)
    s = s |> Enum.uniq() |> length()
    k = k |> Enum.uniq() |> length()
    IO.puts(w * k + s * h - s * k - n)
  end
end
"""
