defmodule Day6 do
    def solve(input) do
        splitted = String.split(input, "\n", trim: true) 
        |> Enum.map(fn str -> 
            [x, y] = String.split(str, ", ") |> Enum.map(&String.to_integer/1)
            {x, y}
        end)

        IO.puts "Day 6"
        IO.puts "1st solution: #{solveFirstPart(splitted)}"
        IO.puts "2nd solution: #{solveSecondPart(splitted)}"
        IO.puts "------"
    end

    defp solveFirstPart(input) do
        boundary = boundary_coords(input)
        ownership = coordinate_ownership(input)

        coord = Enum.filter(input, fn xy ->
            # Filter out coordinates that own infinite size areas
            owned = ownership[xy]
            MapSet.size(MapSet.intersection(owned, boundary)) == 0
        end)
        |> Enum.max_by(fn xy -> MapSet.size(ownership[xy]) end)

        MapSet.size(ownership[coord])
    end

    defp solveSecondPart(input) do
        plane_coords(input)
        |> Enum.reduce(0, fn xy, acc -> 
            sum_distances = Enum.map(input, &(manhatten_distance(&1, xy))) |> Enum.sum
            if sum_distances < 10_000 do
                acc + 1
            else 
                acc
            end
        end)
    end

    defp coordinate_ownership(input) do
        plane_coords(input)
        |> Enum.reduce(Map.new(), fn xy, acc -> 
            distances = Enum.map(input, &({&1, manhatten_distance(&1, xy)}))
            {_, min_distance} = Enum.min_by(distances, fn {_, dist} -> dist end)

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