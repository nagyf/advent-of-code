defmodule S002 do
    def solve() do
        case File.read "002.txt" do
            {:ok, body} ->
                ids = body |> String.split()
                
                IO.puts "1st solution: #{solve_first_part(ids)}"
                IO.puts "2nd solution: #{solve_second_part(ids)}"
            {:error, _} ->IO.puts "Error opening file 002.txt"
        end
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

    def solve_second_part(_ids) do
        
    end
end

S002.solve()