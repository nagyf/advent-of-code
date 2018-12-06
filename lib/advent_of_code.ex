defmodule AdventOfCode do
    def solve() do
        Common.solve("lib/day1.txt", &Day1.solve/1)
        Common.solve("lib/day2.txt", &Day2.solve/1)
        Common.solve("lib/day3.txt", &Day3.solve/1)
        Common.solve("lib/day4.txt", &Day4.solve/1)
        Common.solve("lib/day5.txt", &Day5.solve/1)
        Common.solve("lib/day6.txt", &Day6.solve/1)
    end
end