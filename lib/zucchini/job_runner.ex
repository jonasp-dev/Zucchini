defmodule Zucchini.JobRunner do
    use GenServer

    alias Zucchini.{Job, Worker}
    require Logger

    defmodule State do
        defstruct [:worker, :job, :module]
    end

    @doc false
    def start_link(%Job{queue: queue, queue_pid: queue_pid, worker: worker_pid, task: task} = opts) do
        GenServer.start_link(__MODULE__, opts)
    end


    # end
    @impl true
    def init(%Job{} = opts) do
        {:ok, %State{
            job: opts
        }, {:continue, :run}}
    end

    defp run_job(%State{job: %Job{task: task, worker: worker_pid} = job} = state) do
        #run job
        result =
            case task do
                {module, f, args} -> apply(module, f, args)
            end
        job = %{job | result: result}

        Task.async( fn ->  Worker.job_complete(worker_pid, job) end)

        job
        #terminate job runner
    end


    @impl true
    def handle_continue(:run, state) do
       state = run_job(state)

        {:stop, :normal, state}
    end

    @impl true
  def terminate(:normal, _state), do: :ok
  def terminate(:shutdown, _state), do: :ok
  def terminate({:shutdown, _}, _state), do: :ok
  def terminate(reason, _state) do
    Logger.info("[Zucchini] JobRunner #{inspect self()} stopped because #{inspect reason}")
  end

end
