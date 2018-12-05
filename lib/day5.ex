defmodule Day5 do
    def solve(input) do
        splitted = String.split(input, "", trim: true)
        IO.puts "Day 5"
        IO.puts "1st solution: #{solveFirstPart(splitted)}"
        IO.puts "2nd solution: #{solveSecondPart(splitted)}"
        IO.puts "------"
    end

    defp solveFirstPart(input) when is_list(input) do
        collapse_polymers(input)
    end

    defp solveSecondPart(input) when is_list(input) do
        units(input)
        |> Enum.reduce(MapSet.new, fn {a, aa}, acc ->
                length =
                    input
                    |> Enum.filter(fn x -> x != a && x != aa end)
                    |> collapse_polymers
                MapSet.put(acc, length)
            end)
        |> Enum.min
    end

    defp units(input) when is_list(input) do
        input
        |> Enum.map(&String.upcase/1)
        |> Enum.uniq
        |> Enum.map(fn a -> {String.downcase(a), a} end)
    end

    defp collapse_polymers(input) when is_list(input) do
        collapse(input)
        |> length
    end

    defp collapse(list) when is_list(list), do: collapse(list, [])
    defp collapse([], r), do: Enum.reverse(r)
    defp collapse([a], r) do
        if is_collapsible(a, hd(r)) do collapse([], tl(r)) else collapse([], [a|r]) end
    end
    defp collapse([a|ss], result) do
        b = hd(ss)
        cond do
            is_collapsible(a, b) -> collapse(tl(ss), result)
            length(result) > 0 && is_collapsible(a, hd(result)) -> collapse(ss, tl(result))
            true -> collapse(ss, [a|result])
        end
    end

    defp is_collapsible(a, b) do
        String.upcase(a) == String.upcase(b) && a != b
    end
end