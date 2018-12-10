defmodule Day8 do
    def solve(input) do
        {root, _} = input |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1) |> parse_node
        IO.puts "Day 8"
        IO.puts "1st solution: #{solveFirstPart(root)}"
        IO.puts "2nd solution: #{solveSecondPart(root)}"
        IO.puts "------"
    end

    defp solveFirstPart(root) do
        sum_metadata(root)
    end

    defp solveSecondPart(root) do
        node_value(root)
    end

    defp parse_node([0 | [m | xs]]) do
        {{[], Enum.take(xs, m)}, Enum.drop(xs, m)}
    end
    defp parse_node([n | [m | xs]]) do
        {children, remaining} = parse_children(xs, n)
        {{children, Enum.take(remaining, m)}, Enum.drop(remaining, m)}
    end

    defp parse_children(_, 0), do: []
    defp parse_children(xs, n) do
        Enum.reduce(1..n, {[], xs}, fn _, {nodes, remaining} -> 
            {n, rs} = parse_node(remaining)
            {[n | nodes], rs}
        end)
    end

    defp sum_metadata({[], metadata}) do
        Enum.sum(metadata)
    end
    defp sum_metadata({children, metadata}) do
        child_sum = children
        |> Enum.map(fn node -> sum_metadata(node) end)
        |> Enum.sum

        child_sum + Enum.sum(metadata)
    end

    defp node_value({[], metadata}) do
        Enum.sum(metadata)
    end
    defp node_value({children, metadata}) do
        indices = MapSet.new(metadata)
        children
        |> Enum.with_index
        |> Enum.filter(fn {_, idx} -> MapSet.member?(indices, idx + 1) end)
        |> Enum.reduce(0, fn {child, idx}, acc -> 
            count = Enum.count(metadata, fn m -> m == (idx + 1) end)
            value = node_value(child)
            acc + (count * value)
        end)
    end
end