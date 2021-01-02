defmodule Zucchini.Queue do
    use GenServer
    alias Zucchini.Job

    @type job :: Job.t
    @type name :: Zucchini.queue_name

    defmodule State do
        defstruct [:queue,
            :message_count
        ] 
    end

  
    def start_link(name, opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: via_tuple(name))
    end

    @impl true
    def init(_arg) do
        {:ok, %State{queue: :queue.new, message_count: 0}}
    end

    def enqueue(queue_name, job), do: GenServer.cast(via_tuple(queue_name), {:enqueue, job})
    def dequeue(queue_name), do: GenServer.call(via_tuple(queue_name), {:dequeue})
    def status(queue_name), do: GenServer.call(via_tuple(queue_name), {:status})
    
    defp via_tuple(queue_name) do
        {:via, Zucchini.Registry, {:queue, queue_name}}
    end

    @impl true
    def handle_cast({:enqueue, job}, state) do
        %State{queue: queue, message_count: message_count} = state
        queue = :queue.in(job, queue)
        message_count =  message_count + 1

        state = %State{queue: queue, message_count: message_count}
        {:noreply, state}
    end

    @impl true
    def handle_call({:dequeue}, _from, state) do
        %State{queue: queue, message_count: message_count} = state
        {job, queue} = :queue.out(queue)
  
        message_count = 
            case job do
                :empty ->
                    0
                _ ->
                    message_count - 1
            end

        state = %State{queue: queue, message_count: message_count}
        {:reply, state, state}
    end

    @impl true
    def handle_call({:status}, _from, state) do
        {:reply, state, state}
    end
    @impl true
    def handle_info({:SHUTDOWN, from, reason}, state) do
        IO.puts "Exit pid: #{inspect from} reason: #{inspect reason}"
        {:noreply, state}
        end
    @impl true
    def handle_info({:EXIT, from, reason}, state) do
    IO.puts "Exit pid: #{inspect from} reason: #{inspect reason}"
    {:noreply, state}
    end

    @spec do_child_spec(name, [any()]) :: Supervisor.child_spec()
    def do_child_spec(name, args) do
        args
        |> child_spec
        |> Map.put(:id, name)
    end

end