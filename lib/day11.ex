defmodule Day11 do
    @gridsize 300

    def solve(input) do
        serial = input |> String.to_integer
        IO.puts "Day 11"
        IO.puts "1st solution: #{solveFirstPart(serial)}"
        IO.puts "2nd solution: #{solveSecondPart(serial)}"
        IO.puts "------"
    end

    defp solveFirstPart(serial) do
        {{x,y}, _} = grid(@gridsize)
        |> Enum.reduce(Map.new, fn {x,y}, acc -> 
            Map.put(acc, {x,y}, power_level(x, y, serial)) 
        end)
        |> calculate_sums
        |> calculate_nxn_sums
        |> Map.to_list
        |> Enum.max_by(fn {_, power} -> power end)

        "#{x}, #{y}"
    end

    defp solveSecondPart(serial) do
        sums = grid(@gridsize)
        |> Enum.reduce(Map.new, fn {x,y}, acc -> 
            Map.put(acc, {x,y}, power_level(x, y, serial)) 
        end)
        |> calculate_sums

        {{x, y}, _, wh} = Enum.map(1..299, fn wh -> 
            {xy, power} = calculate_nxn_sums(sums, wh, wh)
            |> Map.to_list
            |> Enum.max_by(fn {_, power} -> power end)
            {xy, power, wh}
        end)
        |> Enum.max_by(fn {_, power, _} -> power end)

        "#{x}, #{y}, #{wh}"
    end

    defp calculate_sums(grid) do
        grid(@gridsize)
        |> Enum.reduce(Map.new, fn {x,y}, acc -> 
            value = get_value(grid, x, y) + get_value(acc, x, y-1) + get_value(acc, x-1, y) - get_value(acc, x-1, y-1)
            Map.put(acc, {x,y}, value)
        end)
    end

    defp calculate_nxn_sums(grid, w \\ 3, h \\ 3) do
        grid(@gridsize)
        |> Enum.filter(fn {x, y} -> x <= @gridsize - w and y <= @gridsize - h and x > 0 and y > 0end)
        |> Enum.reduce(Map.new, fn {x,y}, acc -> 
            sum = get_value(grid, x + w - 1, y + h - 1) - get_value(grid, x + w - 1, y - 1) - get_value(grid, x-1, y + h - 1) + get_value(grid, x - 1, y - 1)
            Map.put(acc, {x,y}, sum)
        end)
    end

    defp get_value(_, x, y) when x < 1 or y < 1, do: 0
    defp get_value(grid, x, y), do: Map.get(grid, {x, y})

    defp grid(n) do
        for x <- 1..n, y <- 1..n, do: {x,y}
    end

    defp power_level(x, y, serial) do
        id = rack_id(x)
        hundreds_digit((id * y + serial) * id) - 5
    end

    defp hundreds_digit(x) do
        x / 100 |> trunc |> Integer.digits |> Enum.reverse |> hd
    end

    defp rack_id(x) do
        x + 10
    end
end