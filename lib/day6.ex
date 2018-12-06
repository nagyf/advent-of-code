defmodule Day6 do
    def solve(input) do
        splitted = String.split(input, "\n", trim: true) 
        |> Enum.map(fn str -> 
            [x, y] = String.split(str, ", ") 
            {String.to_integer(x), String.to_integer(y)}
        end)

        IO.puts "Day 6"
        IO.puts "1st solution: #{solveFirstPart(splitted)}"
        IO.puts "2nd solution: #{solveSecondPart(splitted)}"
        IO.puts "------"
    end

    defp solveFirstPart(input) do
        boundary = boundary_coords(input)
        owners = coordinate_ownership(input)

        coord = Enum.filter(input, fn xy ->
            owned = owners[xy]
            MapSet.size(MapSet.intersection(owned, boundary)) == 0
        end)
        |> Enum.max_by(fn xy -> MapSet.size(owners[xy]) end)

        MapSet.size(owners[coord])
    end

    defp solveSecondPart(_input) do
    end

    defp coordinate_ownership(input) do
        coords = plane_coords(input)
        Enum.reduce(coords, Map.new(), fn xy, acc -> 
            distances = Enum.map(input, fn ab -> 
                {ab, manhatten_distance(xy, ab)}
            end)

            min_distance = Enum.map(distances, fn {_, dist} -> dist end) |> Enum.min

            owners = distances |> Enum.filter(fn {_, dist} -> dist == min_distance end) |> Enum.map(fn {ab, _} -> ab end)
            if length(owners) == 1 do
                Map.update(acc, hd(owners), MapSet.put(MapSet.new(), xy), &(MapSet.put(&1, xy)))
            else
                acc
            end
        end)
    end

    defp plane_coords(input) do
        {x, y, mx, my} = bounding_box(input)
        for i <- x..mx, j <- y..my, do: {i,j}
    end

    defp boundary_coords(input) do
        {x, y, mx, my} = bounding_box(input)
        coords = for i <- x..mx, j <- y..my, i == x or i == mx or j == y or j == my, do: {i,j}
        Enum.into(coords, MapSet.new())
    end

    defp manhatten_distance({x1, y1}, {x2, y2}) do
        abs(x1 - x2) + abs(y1 - y2)
    end

    defp bounding_box(input) do
        xs = Enum.map(input, fn {x, _} -> x end)
        ys = Enum.map(input, fn {_, y} -> y end)

        min_x = xs |> Enum.min
        min_y = ys |> Enum.min
        max_x = xs |> Enum.max
        max_y = ys |> Enum.max

        { min_x, min_y, max_x, max_y }
    end
end