# **Zucchini Job Queue**
A job queue/worker pool written in Elixir 

```elixir
#Start a queue and run a task
defmodule ExampleWorker do
    def add_two_numbers(a,b) do
        a+b
    end
end

Zucchini.start(:queue_name)
Zucchini.create_job(ExampleWorker, :add_two_numbers, [2, 3])
|> Zucchini.async(:queue_name)
```