# **Zucchini Job Queue**
A job queue/worker pool written in Elixir 

```elixir
Define a module with a function (ExampleWorker is already defined in the project)
defmodule Zucchini.ExampleWorker do

    def add(a, b) do
        {:ok, a+b}
    end

    def add(a, b, c) do
        {:ok, a+b+c}
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

# Start queue -> create a job -> push job onto queue
iex> Zucchini.start(:queue_name)
iex> Zucchini.create_job(Zucchini.ExampleWorker, :add, [2, 3]) |> Zucchini.async(:queue_name, [{:reply, true}])

## Reply is in caller's message queue 
iex> Process.info(self(), :messages)

# Using erlang observer we can take a look at our supervision tree
iex> :observer.start
```
