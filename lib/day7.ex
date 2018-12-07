defmodule Day7 do
    def solve(input) do
        splitted = String.split(input, "\n", trim: true)
        IO.puts "Day 7"
        IO.puts "1st solution: #{solveFirstPart(splitted)}"
        IO.puts "2nd solution: #{solveSecondPart(splitted)}"
        IO.puts "------"
    end

    defp solveFirstPart(input) do
        parse_edges(input)
        |> build_graph
        |> topological_sort
    end

    defp solveSecondPart(_input) do
    end

    defp parse_edges(input) do
        regex = ~r{Step (\w) must be finished before step (\w) can begin.}
        input
        |> Enum.map(&(Regex.scan(regex, &1)))
        |> Enum.map(fn [[_, src, dst]] -> {src, dst} end)
    end

    defp build_graph(edges) do
        Enum.reduce(edges, Map.new(), fn {src, dst}, graph ->
            srcs = MapSet.new([src])
            Map.update(graph, dst, srcs, &(MapSet.union(&1, srcs)))
            |> Map.update(src, MapSet.new, &(&1))
        end)
    end

    defp topological_sort(graph) do
        topological_sort(graph, [], zero_in_degree_nodes(graph))
    end
    defp topological_sort(_, result, []), do: Enum.reverse(result)
    defp topological_sort(graph, result, [n | _]) do
        updated_graph = graph
        |> remove_node(n)
        |> remove_edge(n)
        topological_sort(updated_graph, [n | result], zero_in_degree_nodes(updated_graph))
    end

    defp remove_node(graph, node) do
        Map.delete(graph, node)
    end

    defp remove_edge(graph, removable) do
        graph
        |> Map.keys
        |> Enum.reduce(graph, fn k, g -> 
            Map.put(g, k, MapSet.delete(g[k], removable))
        end)
    end

    defp zero_in_degree_nodes(graph) do
        graph
        |> Map.to_list
        |> Enum.filter(fn {_, values} -> MapSet.size(values) == 0 end)
        |> Enum.map(fn {key, _} -> key end)
        |> Enum.sort
    end
end