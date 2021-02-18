defmodule Zucchini.ExampleWorker do
    
    def add(a, b) do
        {:ok, a+b}
    end

    def reverse(list) do
        res = Enum.reverse(list)
        {:ok, res}
    end
end