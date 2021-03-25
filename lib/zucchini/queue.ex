defmodule Zucchini.Queue do
    use GenServer
    alias Zucchini.{Job, JobRunner, Message, Registry, Worker, Workers, WorkerCache}

    @type job :: Job.t
    @type name :: Zucchini.queue_name

    defmodule State do
        defstruct [:queue,
            :module,
            :worker_cache
        ] 
    end

    def start_link(%{name: queue_name} = opts) do
        GenServer.start_link(__MODULE__, opts, name: via_tuple(queue_name))
    end

    @impl true
    def init(%{name: queue_name} = arg) do
        {:ok, worker_cache_pid} = WorkerCache.start_link(%{name: queue_name})
        Workers.start_workers(queue_name, worker_cache_pid, Zucchini.ExampleWorker, %{})
        {:ok, %State{queue: :queue.new, worker_cache: worker_cache_pid}}
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
    def handle_call({:enqueue, job}, _from, %State{worker_cache: cache_pid}= state) do
        #check if available worker
        worker_available = WorkerCache.available?(cache_pid)

       {job, state} =
            case worker_available do
                true ->
                    {worker, _cache} = WorkerCache.checkout(cache_pid)
                    job =
                    job
                    |> struct(worker: worker)
                    res = Worker.run(worker, job)
                    {job, state}
                _ ->
                    {job, state} = do_enqueue(job, state)
            end
  
        {:reply, {:ok, job}, state}
    end
   

    @impl true
    def handle_call({:dequeue}, _from, state) do
        %State{queue: queue} = state

        # TODO: Check for empty queue
        {{:value, j} = job, queue} = :queue.out(queue)
        worker = JobRunner.start_link(j)
        # Zucchini.Worker.start_link(j)

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
    def do_child_spec(%{name: name} = args) do
       spec =
        args
        |> child_spec
        |> Map.put(:id, name)

        spec
    end

end
