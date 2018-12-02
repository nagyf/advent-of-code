defmodule Common do
    def solve(filename, fun) do
        case File.read filename do
            {:ok, body} -> fun.(body)
            {:error, _} -> IO.puts "Error opening file: #{filename}"
        end
    end
end