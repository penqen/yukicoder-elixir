defmodule P7Test do
	use ExUnit.Case
	doctest P7
	alias P7

	import TestHelper, only: [mesure: 3]

	test "01.txt", do: assert P7.solve(5) == true
	test "02.txt", do: assert P7.solve(12) == false
	test "03.txt", do: assert P7.solve(100_000) == true
	test "04.txt", do: assert P7.solve(2_252) == true
	test "05.txt", do: assert P7.solve(1_075) == true
	test "06.txt", do: assert P7.solve(1_059) == false
	test "07.txt", do: assert P7.solve(5_143) == true
	test "08.txt", do: assert P7.solve(4_145) == true
	test "09.txt", do: assert P7.solve(2_675) == true
	test "10.txt", do: assert P7.solve(6_447) == false
	test "99sys01.txt", do: assert P7.solve(4_171) == true
	test "99sys02.txt", do: assert P7.solve(8_359) == true
	test "99sys03.txt", do: assert P7.solve(8_643) == true
	test "sys01.txt", do: assert P7.solve(9_981) == false
	test "sys02.txt", do: assert P7.solve(9_711) == false
	test "sys03.txt", do: assert P7.solve(9_299) == true

	@tag timeout: :infinity
	test "time" do
		algs = [
			[&P7.solve/1, [10_000], "dp"],
			[&P7.solve_light/1, [10_000], "dp(L)"],
			[&P7.solve_full/1, [10_000], "dp(FL)"]
		]

		mesure("10_000", 10, algs)
	end

end