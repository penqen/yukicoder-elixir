defmodule P6Test do    
  use ExUnit.Case    
  doctest P6    
  alias P6

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

  @tag timeout: :infinity
  test "time" do
    {_time, res} = :timer.tc(&P6.solve/2, [2, 2])
    assert res == 2
    {_time, res} = :timer.tc(&P6.solve/2, [1, 11])
    assert res == 3
    {_time, res} = :timer.tc(&P6.solve/2, [10, 100])
    assert res == 31


    n = 10

    fn_algs = fn range ->
      [
        [&P6.stream/2, "strm"],
        [&P6.prime/2, "prim"],
        [&P6.prime_n/2, "pr_n"],
        [&P6.prime_w/2, "pr_w"],
        [&P6.prime_d/2, "pr_d"],
        [&P6.solve/2, "slv"],
        [&Main.solve/2, "main"]
      ]
      |> Enum.map(fn list ->
        List.insert_at(list, 1, range)
      end)
    end

    mesure("2 - 200_000 #{n} times", n, fn_algs.([2, 200_000]))
    mesure("100_000 - 200_000 #{n} times", n, fn_algs.([100_000, 200_000]))
    mesure("70_000 - 200_000 #{n} times", n, fn_algs.([70_000, 200_000]))
    mesure("168_398 - 194_102 #{n} times", n, fn_algs.([168_398, 194_102]))
  end
end