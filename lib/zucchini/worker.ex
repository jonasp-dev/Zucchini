defmodule Zucchini.Worker do
    use GenServer

    alias Zucchini.Job
    alias Zucchini.JobRunner
    alias Zucchini.WorkerCache
    @type private :: term

    @callback init(args :: term) :: {:ok, state :: private}

    # :queue - name of queue worker belongs to
    # :queue_pid - pid of queue
    # :module - module worker handles
    # :{ready, false} - whether the worker is ready, i.e: not performing a job
    defmodule State do
        defstruct [
            :queue,
            :queue_pid,
            :worker_cache,
            {:ready, false}
        ]
    end
    def start_link(opts) do
        worker = GenServer.start_link(__MODULE__, opts)
    end

    def run(worker, job) do
        GenServer.call(worker, {:run, job})
    end

    defp do_run(job, state) do
        # call JobRunner and do job
        {:ok, job_runner} = JobRunner.start_link(job)
    end

    def job_complete(worker, job), do: GenServer.cast(worker, {:job_complete, job})

    @impl true
    def init([supervisor |  opts] = start_args) do
        #Add worker to registry group
        [%{worker_cache: worker_cache} = head | _rest] = opts
        {:ok, %State{
            ready: true,
            worker_cache: worker_cache
        }}
    end

    @impl true
    def handle_call({:run, job}, _from, state) do
        {:reply, do_run(job, state), state}
    end

    @impl true
    def handle_cast({:job_complete, %Job{from: from, worker: worker}= job}, %{worker_cache: worker_cache} = state) do
        send(from, job)
        WorkerCache.checkin(worker_cache, worker)
        {:noreply, state}
    end


    def child_spec(opts) do
        %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, [opts]},
            restart: :transient
        }
    end

end
