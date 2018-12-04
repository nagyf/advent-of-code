defmodule ShiftRecord do
    defstruct datetime: Timex.now, action: :wake_up, id: ""

    def fill_ids(rr), do: fill_ids(rr, nil)
    def fill_ids([], _), do: []
    def fill_ids([r|rr], id) do
        cond do
            r.id == nil -> [%ShiftRecord{r | id: id} | fill_ids(rr, id)]
            true -> [r | fill_ids(rr, r.id)]
        end
    end

    def parse(str) do
        [datetime] = Regex.scan(~r{\d+-\d+-\d+ \d+:\d+}, str) |> List.flatten 
        %ShiftRecord{
            datetime: Timex.parse!(datetime, "{YYYY}-{0M}-{0D} {h24}:{m}"),
            action: parse_action(str),
            id: parse_id(str)
        }
    end

    defp parse_action(str) do
        cond do
            Regex.match?(~r{wakes up}, str) -> :wake_up
            Regex.match?(~r{falls asleep}, str) -> :fall_asleep
            Regex.match?(~r{begins shift}, str) -> :begin_shift
        end
    end

    defp parse_id(str) do
        id = Regex.scan(~r{#\d+}, str) |> List.flatten
        cond do
            length(id) > 0 -> Regex.scan(~r/\d+/, hd(id)) |> List.flatten |> hd |> String.to_integer
            true -> nil
        end
    end
end

defmodule Day4 do
    def solve(input) do
        records = String.split(input, ~r{\n}) |> Enum.map(&ShiftRecord.parse/1) |> Enum.sort_by(&(&1.datetime), &(Timex.compare(&1, &2) == -1)) |> ShiftRecord.fill_ids
        IO.puts "1st solution: #{solveFirstPart(records)}"
        IO.puts "2nd solution: #{solveSecondPart(records)}"
    end

    defp solveFirstPart(records) do
        {id, _} = asleep_times(records) |> Map.to_list |> Enum.max_by(fn {_, time} -> time end)
        {minute, _} = Enum.filter(records, &(&1.id == id)) |> most_asleep_minute()
        id * minute
    end

    defp solveSecondPart(records) do
        {id, {minute, _}} = Enum.map(records, &(&1.id)) 
        |> Enum.into(MapSet.new)
        |> Enum.reduce(Map.new(), fn id, acc ->
            most_asleep = Enum.filter(records, &(&1.id == id)) |> most_asleep_minute()
            Map.put(acc, id, most_asleep)
        end)
        |> Enum.max_by(fn {_, {_, times}} -> times end)

        id * minute
    end

    defp asleep_times(records), do: asleep_times(records, Map.new(), nil)
    defp asleep_times([], map, _), do: map
    defp asleep_times([r|rs], map, start) do
        case r.action do
            :begin_shift -> asleep_times(rs, map, r.datetime)
            :fall_asleep -> asleep_times(rs, map, r.datetime)
            :wake_up ->
                time_asleep = Timex.diff(r.datetime, start, :minutes)
                updated_map = Map.update(map, r.id, time_asleep, &(&1 + time_asleep))
                asleep_times(rs, updated_map, r.datetime)
        end
    end

    defp most_asleep_minute(records) do
        try do
            asleep_intervals(records)
            |> Enum.reduce(Map.new(), fn interval, map ->
                Enum.reduce(interval, map, fn minute, acc ->
                    Map.update(acc, minute, 1, &(&1 + 1))
                end)
            end)
            |> Map.to_list
            |> Enum.max_by(fn {_, times} -> times end)
        rescue
            _ -> {-1, -1}
        end
    end

    defp asleep_intervals(records), do: asleep_intervals(records, [], nil)
    defp asleep_intervals([], intervals, _), do: intervals
    defp asleep_intervals([r|rs], intervals, start) do
        case r.action do
            :begin_shift -> asleep_intervals(rs, intervals, nil)
            :fall_asleep -> asleep_intervals(rs, intervals, r.datetime)
            :wake_up ->
                updated_intervals = [interval_minutes(start, r.datetime) | intervals]
                asleep_intervals(rs, updated_intervals, nil)
        end
    end

    defp interval_minutes(from, to) do
        if Timex.compare(from, to) == 0 do
            []
        else
            [from.minute | interval_minutes(Timex.shift(from, minutes: 1), to)]
        end
    end
end
