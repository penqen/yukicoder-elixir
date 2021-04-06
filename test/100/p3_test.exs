defmodule P3Test do
	use ExUnit.Case
  doctest P3

  import P3

  describe "time" do
    test "10000" do
      {time_worst, res_worst} = :timer.tc(&solve/1, [9997])
      {time, res} = :timer.tc(&solve/1, [10000])
      IO.puts ""
      IO.puts "time : #{time} μs"
      IO.puts "time : #{time_worst} μs"
      assert res == 1610
    end
  end
end