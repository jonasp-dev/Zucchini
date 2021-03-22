# **Zucchini Job Queue**
A job queue/worker pool written in Elixir 

	#Start a queue and run a task
    defmodule ExampleWorker do
	    def add_two_numbers(a,b) do
		    a+b
	    end
    end
    Zucchini.start_queue(%{name: queue_name})
    Zucchini.async(&ExampleWorker.add_two_numers/2, queue_name)