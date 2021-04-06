defmodule TestHelper do
  def mesure(label, times, fn_list) do
    memo = Enum.reduce(fn_list, %{}, fn [_, _, label], memo ->
      Map.put(memo, label, 0)
    end)
    memo = 1..times
    |> Enum.reduce(memo, fn _, memo ->
      Enum.reduce(fn_list, memo, fn [fun, args, label], memo ->
        {time, _} = :timer.tc(fun, args)
        Map.put(memo, label, memo[label] + time / times)
      end)
    end)

    IO.puts label
    Enum.each(fn_list, fn [_, _, label] ->
      IO.puts "\t#{label} \t: #{memo[label] / 1000} ms"
    end)
  end
end

ExUnit.configure(timeout: 5_000_000)
ExUnit.start()
