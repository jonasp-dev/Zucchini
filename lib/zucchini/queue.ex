defmodule Zucchini.Queue do
    use GenServer
    alias Zucchini.{Job, Message}

    @type job :: Job.t
    @type name :: Zucchini.queue_name

    defmodule State do
        defstruct [:queue,
            :module
        ] 
    end

    def start_link(queue_name, opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: via_tuple(queue_name))
    end

    @impl true
    def init(arg) do
        {:ok, %State{queue: :queue.new}}
    end

    def enqueue(queue_name, job), do: GenServer.call(via_tuple(queue_name), {:enqueue, job})
    def dequeue(queue_name), do: GenServer.call(via_tuple(queue_name), {:dequeue})
    def status(queue_name), do: GenServer.call(via_tuple(queue_name), {:status})

    defp do_enqueue(job, %State{queue: queue, module: module} = state) do
      job =
      job
      |> struct(enqueued_at: System.system_time(:millisecond))
      
      state = %{state | queue: :queue.in(job, queue)}
      {job, state}
    end
    
    defp via_tuple(queue_name) do
        {:via, Zucchini.Registry, {:queue, queue_name}}
    end

    @impl true
    def handle_call({:enqueue, job}, _from, state) do
        {job, state} = do_enqueue(job, state)
        {:reply, {:ok, job}, state}
    end
   

    @impl true
    def handle_call({:dequeue}, _from, state) do
        %State{queue: queue} = state
        {job, queue} = :queue.out(queue)

        state = %{state | queue: queue}
        {:reply, job, state}
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

    @spec do_child_spec(any()) :: Supervisor.child_spec()
    def do_child_spec(name) do
        name
        |> child_spec
        |> Map.put(:id, name)
    end

end
