defprotocol Heapable do
  @type heap() :: struct()
  @type comparator(any, any) :: boolean()

  @doc """
  `comparator/2`を引数に渡し、任意の値を評価するヒープを作成する。
  """
  @callback new(comparator(any, any)) :: heap()

  @doc """
  ヒープが空であるかを返す。
  """
  @callback empty?(heap()) :: boolean()

  @doc """
  ヒープのサイズを返す。
  """
  @callback size(heap()) :: non_neg_integer()

  @doc """
  `comparator/2`に従ったトップの優先度の値を返す。 
  """
  @callback top(heap()) :: any()

  @doc """
  `comparator/2`に従ったトップの値を取り除いた新しいヒープを返す。
  """
  @callback pop(heap()) :: heap() | nil

  @doc """
  新しい値を追加したヒープを返す。
  """
  @callback push(heap(), any()) :: heap()
end