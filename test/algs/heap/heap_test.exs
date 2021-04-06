defmodule HeapTest do
	use ExUnit.Case

	alias Heap
	alias BinaryHeap, as: Heap0
	alias BinaryTupleHeap, as: Heap1
	alias FibonacciHeap, as: Heap2

	import TestHelper, only: [mesure: 3]

	def into(mod, list) do
		Enum.into(list, mod.new(&(&1 < &2)))
	end

	def to_list(mod, list) do
		list
		|> Enum.into(mod.new(&(&1 < &2)))
		|> Enum.to_list()
	end

	def meld(mod, init, list) do
		Enum.reduce(list, Enum.into(init, mod.new(&(&1 < &2))), fn
			v, heap ->
				heap
				|> mod.pop()
				|> mod.push(v)
		end)
	end

	test "mesure" do
		init = 1..1000 |> Enum.shuffle()
		list = 1..1000 |> Enum.shuffle()

		algs_into = fn args ->
			[
#				[&into/2, [Heap0, args], "binary"],
				[&into/2, [Heap1, args], "tuple"],
				[&into/2, [Heap2, args], "fib"],
				[&into/2, [Heap, args], "heap"],
			]
		end

		algs_to_list = fn args ->
			[
#				[&to_list/2, [Heap0, args], "binary"],
				[&to_list/2, [Heap1, args], "tuple"],
				[&to_list/2, [Heap2, args], "fib"],
				[&to_list/2, [Heap, args], "heap"],
			]
		end

		algs_meld = fn init, args ->
			[
#				[&meld/3, [Heap0, init, args], "binary"],
				[&meld/3, [Heap1, init, args], "tuple"],
				[&meld/3, [Heap2, init, args], "fib"],
				[&meld/3, [Heap, init, args], "heap"],
			]
		end

		times = 10000
		IO.puts("# iteration: #{times}")
		IO.puts("## push 10000 element")
		mesure("into", times, algs_into.(list))
		IO.puts("## push 10000 and transform to list")
		mesure("to_list", times, algs_to_list.(list))
		IO.puts("## init 10000 elements, pop and push 100000 elements")
		mesure("meld", times, algs_meld.(init, list))
	end
end