defmodule Day2 do
    def solve(input) do
        ids = input |> String.split()
        
        IO.puts "Day 2"
        IO.puts "1st solution: #{solve_first_part(ids)}"
        IO.puts "2nd solution: #{solve_second_part(ids)}"
        IO.puts "------"
    end

    def solve_first_part(ids) do
        {twos, threes} = Stream.uniq(ids)
        |> Stream.map(&String.codepoints/1)
        |> Stream.map(&Enum.sort/1)
        |> count_2_3

        twos * threes
    end

    defp count_2_3(str_arr) do
        Enum.reduce(str_arr, {0, 0}, fn xs, {twos, threes} ->
            # Count each letter
            counts = Enum.reduce(xs, Map.new(), fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
            
            result = Map.values(counts) 
            |> Enum.filter(&(&1 == 2 || &1 == 3))
            |> Enum.uniq()
            |> Enum.reduce(%{2 => 0, 3 => 0}, fn x, acc -> Map.update!(acc, x, &(&1 + 1)) end)
            
            { twos + result[2], threes + result[3] }
        end)
    end

    def solve_second_part(ids) do
        Enum.map(ids, &String.codepoints/1)
        |> pairs
        |> Stream.map(fn {xs, ys} -> {{xs, ys}, lcs(xs, ys)} end)
        |> Stream.drop_while(fn {{xs, _}, {len, _seq}} -> 
            abs(length(xs) - len) > 1
        end)
        |> Enum.map(fn {_, {_, seq}} -> seq end)
        |> Enum.take(1)
        |> hd
    end

    defp pairs([]), do: []
    defp pairs([x|xs]) do
        (for y <- xs, do: {x, y}) ++ pairs(xs)
    end

    defp indexed(xs) do
        Enum.zip(1..length(xs), xs)
    end

    defp lcs(xs, ys) do
        xsi = indexed(xs)
        ysi = indexed(ys)
        # Prepare the C table
        mx = Stream.cycle([0]) |> Stream.zip(0..length(xsi)) |> Enum.reduce(Map.new(), fn {i,j}, acc -> Map.put(acc, {j,i}, 0) end)
        my = Stream.cycle([0]) |> Stream.zip(0..length(ysi)) |> Enum.reduce(Map.new(), fn {i,j}, acc-> Map.put(acc, {i,j}, 0) end)
        
        # Fill the C table
        c = Enum.reduce(ysi, Map.merge(mx, my), fn y, c -> lcs(xsi, y, c) end)

        {
            lcs_length(c, length(xsi), length(ysi)),
            lcs_sequence(c, xsi, ysi)
        }
    end

    defp lcs(xs, {j, y}, c) do
        Enum.reduce(xs, c, fn {i, x}, acc ->
            cond do
                x == y -> Map.put(acc, {i,j}, acc[{i-1, j-1}] + 1)
                x != y -> Map.put(acc, {i,j}, max(acc[{i-1, j}], acc[{i, j-1}]))
            end
        end)
    end

    defp lcs_length(c, size_x, size_y) do
        c[{size_x, size_y}]
    end

    defp lcs_sequence(c, xsi, ysi) do
        lcs_sequence_rec(c, Enum.reverse(xsi), Enum.reverse(ysi)) |> Enum.reverse
    end
    defp lcs_sequence_rec(_c, _xs, []), do: []
    defp lcs_sequence_rec(_c, [], _ys), do: []
    defp lcs_sequence_rec(c, [{i, x}|xs]=xss, [{j, y}|ys]=yss) do
        cond do
            x == y -> [x | lcs_sequence_rec(c, xs, ys)]
            c[{i, j-1}] > c[{i-1, j}] -> lcs_sequence_rec(c, xss, ys)
            true -> lcs_sequence_rec(c, xs, yss)
        end
    end
end
