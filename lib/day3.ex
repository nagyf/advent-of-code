defmodule Rectangle do
    defstruct x: 0, y: 0, w: 0, h: 0

    def coordinates(rect) do
        x = rect.x + 1
        xw = rect.x + rect.w
        y = rect.y + 1
        yh = rect.y + rect.h
        for i <- x..xw, j <- y..yh, do: {i,j}
    end
end

defmodule Fabric do
    defstruct id: "", dimensions: %Rectangle{}

    def parse(str) do
        [id, x, y, w, h] = Regex.scan(~r{-?\d+}, str) |> List.flatten |> Enum.map(&String.to_integer/1)
        %Fabric{
            id: Integer.to_string(id), 
            dimensions: %Rectangle{x: x, y: y, w: w, h: h}
        }
    end
end

defmodule Day3 do
    def solve(input) do
        fabrics = String.split(input, ~r{\n}) |> Enum.map(&Fabric.parse/1)
        IO.puts "Day 3"
        IO.puts "1st solution: #{solveFirstPart(fabrics)}"
        IO.puts "2nd solution: #{solveSecondPart(fabrics)}"
        IO.puts "------"
    end

    defp solveFirstPart(fabrics) do
        overlappingClaims(fabrics)
        |> Enum.count
    end

    defp solveSecondPart(fabrics) do
        ids = Enum.map(fabrics, &(&1.id)) 
        |> Enum.into(MapSet.new())

        overlappingIds = overlappingClaims(fabrics)
        |> Enum.flat_map(fn {_, ids} -> ids end)
        |> Enum.uniq()
        |> Enum.into(MapSet.new())

        MapSet.difference(ids, overlappingIds) 
        |> MapSet.to_list
    end

    defp overlappingClaims(fabrics) do
        claims(fabrics)
        |> Map.to_list
        |> Enum.filter(fn {_, ids} -> length(ids) > 1 end)
    end

    defp claims(fabrics) do
        Enum.reduce(fabrics, Map.new(), fn fabric, claims ->
            claim_map(fabric)
            |> Map.merge(claims, fn _, m1, m2 -> m1 ++ m2 end)
        end)
    end

    defp claim_map(fabric) do
        Rectangle.coordinates(fabric.dimensions)
        |> Enum.reduce(Map.new(), fn ij, acc ->
            Map.update(acc, ij, [fabric.id], fn ids -> [fabric.id | ids] end)
        end)
    end
end