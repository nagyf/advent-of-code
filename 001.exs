defmodule S001 do
    def solve() do
        {:ok, body} = File.read "001.txt"
        frequencyChanges = Enum.map(String.split(body), fn(x) -> String.to_integer(x) end)
        frequency = solveFirstPart(frequencyChanges)
        firstDuplicate = solveSecondPart(frequencyChanges)
        IO.puts "#1 The resulting frequency is: #{frequency}"
        IO.puts "#2 The first frequency reached twice: #{firstDuplicate}"
    end

    defp solveFirstPart(frequencyChanges) do
        Enum.reduce(frequencyChanges, fn(x, acc) -> x + acc end)
    end

    defp solveSecondPart(frequencyChanges) do
        startWith = 0
        findFirstDup(startWith, frequencyChanges)
    end

    defp findFirstDup(startWith, frequencyChanges) do
        cache = MapSet.new()
        findFirstDup(startWith, frequencyChanges, cache)
    end

    defp findFirstDup(acc, list, cache) do
        [next | _] = list
        acc = acc + next
        if MapSet.member?(cache, acc) do
            acc
        else
            findFirstDup(acc, rotate(list), MapSet.put(cache, acc))
        end
    end

    defp rotate(list) when list == [] do
        []
    end

    defp rotate([head | tail]) do
        tail ++ [head]
    end
end

S001.solve()