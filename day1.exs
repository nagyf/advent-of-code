defmodule Day1 do
    def solve(input) do
        frequencyChanges = String.split(input) |> Enum.map(&String.to_integer/1)
        
        IO.puts "1st solution: #{solveFirstPart(frequencyChanges)}"
        IO.puts "2nd solution: #{solveSecondPart(frequencyChanges)}"
    end

    defp solveFirstPart(frequencyChanges) do
        Enum.sum(frequencyChanges)
    end

    defp solveSecondPart(frequencyChanges) do
        startWith = 0
        findFirstDup(frequencyChanges, startWith)
    end

    defp findFirstDup(frequencyChanges, startWith) do
        cache = MapSet.new()
        findFirstDup(frequencyChanges, startWith, cache)
    end

    defp findFirstDup(list, acc, cache) do
        [next | _] = list
        acc = acc + next
        if MapSet.member?(cache, acc) do
            acc
        else
            findFirstDup(rotate(list), acc, MapSet.put(cache, acc))
        end
    end

    defp rotate([head | tail]) do
        tail ++ [head]
    end
end

Code.require_file("common.ex")
Common.solve("day1.txt", &Day1.solve/1)