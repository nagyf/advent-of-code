defmodule Day1 do
    def solve() do
        case File.read "day1.txt" do
            {:ok, body} ->
                frequencyChanges = body
                |> String.split()
                |> Enum.map(&String.to_integer/1)
                
                IO.puts "1st solution: #{solveFirstPart(frequencyChanges)}"
                IO.puts "2nd solution: #{solveSecondPart(frequencyChanges)}"
            {:error, _} ->IO.puts "Error opening file 001.txt"
        end
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

Day1.solve()