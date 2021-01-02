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

    @spec start_queue(name, []) :: :ok | {:error, :not_running}
    def start_queue(name, opts) do
        IO.inspect Queue.child_spec(name)
        with {:ok, child} <- Supervisor.start_child(__MODULE__, Queue.do_child_spec(name, [name: name])) do
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