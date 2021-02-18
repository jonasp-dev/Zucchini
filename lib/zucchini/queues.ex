defmodule Zucchini.Queues do
    use Supervisor
    alias Zucchini.Queue
    @type name :: Zucchini.queue_name

    @spec queues() :: [name]
    def queues do
        __MODULE__
        |> Supervisor.which_children
        |> Enum.map(fn {queue, _, _, _} -> queue end)
        |> Enum.sort
    end


    def start_queue(args) do
        with {:ok, child} <- Supervisor.start_child(__MODULE__, Queue.do_child_spec(args)) do
            {:ok, child}
        end
    end

    def start_link(args) do
        Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    end
    
    @impl true
    def init(_args) do
        Supervisor.init([], strategy: :one_for_one)
    end

end