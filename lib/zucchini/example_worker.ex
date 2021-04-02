defmodule Zucchini.ExampleWorker do

    def add(a, b) do
        {:ok, a+b}
    end

    def reverse(list) do
        res = Enum.reverse(list)
        {:ok, res}
    end

    def sleep_task(milliseconds) do
         Process.sleep(milliseconds)
         IO.puts("finished sleeping...")
    end
end
