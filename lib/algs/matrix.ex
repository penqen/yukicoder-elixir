defmodule Matrix do
  @moduledoc """
  多次元配列を取り扱うヘルパーモジュールです。

  ## 2 x 3 行列の場合

    iex> Matrix.new(2, 3)
    [
      [nil, nil],
      [nil, nil],
      [nil, nil]
    ]

  ## 行列をマップに変換する

    iex> Matrix.new(3, 3)
    ...> |> Matrix.to_map()
    %{
      0 => %{ 0 => nil, 1 => nil, 2 => nil},
      1 => %{ 0 => nil, 1 => nil, 2 => nil},
      2 => %{ 0 => nil, 1 => nil, 2 => nil}
    }

   ## 多次元マップに新しい要素を追加する

    iex> Matrix.put(%{}, [1, 2], 5)
    %{
      1 => %{ 2 => 5 }
    }

    iex> %{1 => %{ 2 => 5 }} 
    ...> |> Matrix.put([1, 3], 2)
    %{
      1 => %{
        2 => 5 ,
        3 => 2
      }
    } 
  
  ## 多次元マップから要素を取得する

    iex> %{ 1 => %{ 2 => 5 , 3 => 2 }} 
    ...> |> Matrix.get(1)
    %{ 2 => 5, 3 => 2}

    iex> %{ 1 => %{ 2 => 5 , 3 => 2 }} 
    ...> |> Matrix.get([1])
    %{ 2 => 5, 3 => 2}

    iex> %{ 1 => %{ 2 => 5 , 3 => 2 }} 
    ...> |> Matrix.get([1, 2])
    5

    iex> %{ 1 => %{ 2 => 5 , 3 => 2 }} 
    ...> |> Matrix.get([2, 4])
    nil

  """

  @type initializer(any, any) :: any

  @spec new(non_neg_integer, non_neg_integer, initializer(any, any)) :: list
  def new(x, y, initial_value_or_fun \\ nil)
  def new(x, y, fun) when is_function(fun) do
    for j <- 0..(y - 1) do
      for i <- 0..(x - 1) do
        fun.(i, j)
      end
    end
  end

  def new(x, y, initial_value) do
    for _j <- 0..(y - 1) do
      for _i <- 0..(x - 1) do
        initial_value
      end
    end
  end

  @spec to_map(list) :: map()
  def to_map(matrix) when is_list(matrix), do: do_to_map(matrix)

  defp do_to_map(matrix, index \\ 0, map \\ %{})
  defp do_to_map([], _index, map), do: map
  defp do_to_map([h | t], index, map),
    do: do_to_map(t, index + 1, Map.put(map, index, do_to_map(h)))
  defp do_to_map(value, _index, _map), do: value

  @spec put(map(), list, any) :: map()
  def put(map, keys, value), do: do_map_put(value, keys, map)
  defp do_map_put(value, keys, map)
  defp do_map_put(value, [], _), do: value
  defp do_map_put(value, [key | tail], nil), do: Map.put(%{}, key, do_map_put(value, tail, Map.get(%{}, key)))
  defp do_map_put(value, [key | tail], map), do: Map.put(map, key, do_map_put(value, tail, Map.get(map, key)))


  @spec get(map(), list | any) :: map() | any()
  def get(map, key_or_keys)
  def get(nil, _key), do: nil
  def get(map, [key | []]), do: Map.get(map, key)
  def get(map, [key | tail]), do: get(Map.get(map, key), tail)
  def get(map, key), do: Map.get(map, key)

end