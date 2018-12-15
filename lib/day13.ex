defmodule Day13 do
    def solve(input) do
        {tracks, carts} = parse(input)
        IO.puts "Day 13"
        IO.puts "1st solution: #{solveFirstPart(tracks, carts)}"
        IO.puts "2nd solution: #{solveSecondPart(tracks, carts)}"
        IO.puts "------"
    end

    defp solveFirstPart(tracks, carts) do
        sorted_carts = Enum.sort(carts, fn {{x1, y1}, _, _}, {{x2, y2}, _, _} -> y1 < y2 or (y1 == y2 and x1 <= x2) end)
        case tick(tracks, sorted_carts) do
            {x,y} -> "#{x}, #{y}"
            new_carts -> solveFirstPart(tracks, new_carts)
        end
    end

    defp solveSecondPart(tracks, carts) do
        sorted_carts = Enum.sort(carts, fn {{x1, y1}, _, _}, {{x2, y2}, _, _} -> y1 < y2 or (y1 == y2 and x1 <= x2) end)
        case tick2(tracks, sorted_carts) do
            [{{x,y}, _, _}] -> "#{x}, #{y}"
            new_carts -> 
                solveSecondPart(tracks, new_carts)
        end
    end

    defp tick(tracks, carts), do: tick(tracks, carts, carts)
    defp tick(_, carts, []), do: carts
    defp tick(tracks, [_|rs]=carts, [c|cs]) do
        case move(tracks, carts, c) do
            {:ok, moved_cart} -> tick(tracks, rs ++ [moved_cart], cs)
            {:crash, crash_pos} -> crash_pos
        end
    end

    defp tick2(tracks, carts), do: tick2(tracks, carts, carts)
    defp tick2(_, carts, []), do: carts
    defp tick2(tracks, [_|rs]=carts, [c|cs]) do
        case move(tracks, carts, c) do
            {:ok, moved_cart} -> tick2(tracks, rs ++ [moved_cart], cs)
            {:crash, crash_pos} -> 
                remaining_carts = Enum.filter(rs, fn {cxy, _, _} -> cxy != crash_pos end)
                remaining_carts_in_tick = Enum.filter(cs, fn {cxy, _, _} -> cxy != crash_pos end)
                tick2(tracks, remaining_carts, remaining_carts_in_tick)
        end
    end

    defp move(tracks, carts, {pos, dir, turn_state}) do
        next_pos = Vector.add(pos, dir)
        track = Map.get(tracks, next_pos)
        moved_cart = turn(track, {next_pos, dir, turn_state})
        crashing = Enum.count(carts, fn {cxy, _, _} -> cxy == next_pos end)
        case crashing do
            0 -> {:ok, moved_cart}
            _ -> {:crash, next_pos}
        end
    end

    defp turn({track, _}, {xy, dir, [d | ds]=turn_state}) do
        case track do
            "/" -> {xy, Vector.mirror_right(dir), turn_state}
            "\\" -> {xy, Vector.mirror_left(dir), turn_state}
            "+" -> 
                next_dir = Vector.rotate(dir, d)
                {xy, next_dir, ds ++ [d]}
            _ -> {xy, dir, turn_state}
        end
    end

    defp parse(input) do
        lines = String.split(input, "\n", trim: true)
        |> Enum.map(fn str -> 
            splitted = String.codepoints(str)
            Enum.zip(splitted, positive_integers(length(splitted)))
        end)

        indexed = Enum.zip(lines, positive_integers(length(lines)))
        {parse_tracks(indexed), parse_carts(indexed)}
    end

    defp parse_tracks(input) do
        Enum.reduce(input, Map.new, fn {line, row}, acc -> 
            Enum.reduce(line, acc, fn {track, col}, tracks -> 
                xy = {col, row}
                connections = parse_track(track, xy)
                Map.update(tracks, xy, {track, connections}, fn {_, c} -> c ++ connections end)
            end)
        end)
    end

    defp parse_track(track, xy) do
        case track do
            "-" -> [Vector.left(xy), Vector.right(xy)]
            "|" -> [Vector.up(xy), Vector.down(xy)]
            "/" -> [Vector.down(xy), Vector.right(xy)]
            "\\" -> [Vector.down(xy), Vector.left(xy)]
            "+" -> [Vector.up(xy), Vector.down(xy), Vector.left(xy), Vector.right(xy)]

            "v" -> [Vector.up(xy), Vector.down(xy)]
            "^" -> [Vector.up(xy), Vector.down(xy)]

            "<" -> [Vector.left(xy), Vector.right(xy)]
            ">" -> [Vector.left(xy), Vector.right(xy)]

            " " -> []
        end
    end

    defp parse_carts(input) do
        Enum.reduce(input, [], fn {line, row}, carts -> 
            Enum.filter(line, fn {t, _ } -> t in ["<", ">", "v", "^"] end)
            |> Enum.reduce(carts, fn {track, col}, acc -> 
                [parse_cart(track, {col, row}) | acc]
            end)
        end)
    end

    defp parse_cart(track, xy) do
        upcoming_dirs = [:left, :straight, :right]
        case track do
            "v" -> {xy, Vector.down({0, 0}), upcoming_dirs}
            "^" -> {xy, Vector.up({0, 0}), upcoming_dirs}
            "<" -> {xy, Vector.left({0, 0}), upcoming_dirs}
            ">" -> {xy, Vector.right({0, 0}), upcoming_dirs}
            true -> nil
        end
    end

    defp positive_integers(n) do
        Stream.iterate(0, &(&1 + 1)) |> Enum.take(n)
    end
end

defmodule Vector do
    def add({x, y}, {vx, vy}) do
        {x + vx, y + vy}
    end
    def up({x, y}), do: {x, y-1}
    def down({x, y}), do: {x, y+1}
    def left({x, y}), do: {x-1, y}
    def right({x, y}), do: {x+1, y}

    def rotate({vx, vy}, rotate_with) do
        [next_vx, next_vy] = rotation_matrix(rotate_with)
        |> Enum.reduce([], fn row, acc -> 
            a = Enum.zip(row, [vx, vy]) |> Enum.map(fn {a, b} -> a*b end) |> Enum.sum 
            acc ++ [a] 
        end)
        {next_vx, next_vy}
    end

    def rotation_matrix(dir) do
        case dir do
            :left -> [[0, 1], [-1, 0]]
            :straight -> [[1, 0], [0, 1]]
            :right -> [[0, -1], [1, 0]]
        end
    end

    def mirror_right({-1, 0}), do: {0, 1}
    def mirror_right({1, 0}), do: {0, -1}
    def mirror_right({0, -1}), do: {1, 0}
    def mirror_right({0, 1}), do: {-1, 0}

    def mirror_left({-1, 0}), do: {0, -1}
    def mirror_left({1, 0}), do: {0, 1}
    def mirror_left({0, -1}), do: {-1, 0}
    def mirror_left({0, 1}), do: {1, 0}
end
