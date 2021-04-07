defmodule Zucchini.Queues do
    use Supervisor
    alias Zucchini.Queue
    require Logger
    @type name :: Zucchini.queue_name

    @spec queues() :: [name]
    def queues do
        __MODULE__
        |> Supervisor.which_children
        |> Enum.map(fn {queue, _, _, _} -> queue end)
        |> Enum.sort
    end


    def start_queue(args) do
        with {:ok, child} <- Supervisor.start_child(__MODULE__, Queue.do_child_spec(args))
            do
                {:ok, child}
            else
                {:error, reason} -> {:error, "Failed to start Queue for reason: #{inspect reason}"}
            end
    end

    def stop_queue(queue_name) do
        with :ok <- Supervisor.terminate_child(__MODULE__, queue_name) do
            Supervisor.delete_child(__MODULE__, queue_name)
            Logger.info("Terminated queue #{inspect queue_name} and workers")
        else
            {:error, reason} ->
                Logger.error("Failed to terminate queue #{inspect queue_name}. Reason: #{inspect reason}")
                :error
        end

    end

    def handle_info(msg, state) do
        Logger.error("Supervisor received unexpected message: #{inspect(msg)}")
        {:noreply, state}
      end

    def start_link(args) do
        Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    end

    @impl true
    def init(_args) do
        Supervisor.init([], strategy: :one_for_one)
    end

end
