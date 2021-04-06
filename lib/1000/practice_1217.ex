defmodule Practice1217 do
  @moduledoc """
  ## Examples

    iex> Practice1217.solve("abcdefghijklmnopqrituvwxyz")
    "stoi"

    iex> Practice1217.solve("abcdefghujklmnopqrstuvwxyz")
    "itou"

    iex> Practice1217.solve("abcdefghijklmnnpqrstuvwxyz")
    "oton"

  """
  def solve(sd) do
    s = "abcdefghijklmnopqrstuvwxyz" |> String.codepoints()
    sd = sd |> String.codepoints()

    s
    |> Enum.with_index()
    |> Enum.find_value(fn {w, i} ->
      if w != Enum.at(sd, i), do: "#{w}to#{Enum.at(sd, i)}"
    end)
  end
end