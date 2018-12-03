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
        [id, _, xy, wh] = String.split(str, " ", trim: true)
        [x, y] = String.trim_trailing(xy, ":") |> String.split(",") |> Enum.map(&String.to_integer/1)
        [width, height] = String.split(wh, "x") |> Enum.map(&String.to_integer/1)
        dimensions = %Rectangle{x: x, y: y, w: width, h: height}
        %Fabric{id: id, dimensions: dimensions}
    end
end

defmodule Day3 do
    def solve(input) do
        fabrics = String.split(input, ~r{\n}) |> Enum.map(&Fabric.parse/1)        
        IO.puts "1st solution: #{solveFirstPart(fabrics)}"
        IO.puts "2nd solution: #{solveSecondPart(fabrics)}"
    end

    defp solveFirstPart(fabrics) do
        claims = Enum.reduce(fabrics, Map.new(), fn fabric, claims ->
            Rectangle.coordinates(fabric.dimensions)
            |> Enum.reduce(claims, fn ij, acc ->
                Map.update(acc, ij, [fabric.id], fn ids -> [fabric.id | ids] end)
            end)
        end)

        Map.to_list(claims) |> Enum.filter(fn {ij, ids} -> length(ids) > 1 end) |> Enum.count()
    end

    defp solveSecondPart(_fabrics) do
    end
end

Code.require_file("common.ex")
Common.solve("day3.txt", &Day3.solve/1)