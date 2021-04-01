defmodule Zucchini do

  alias Zucchini.{Job, Registry, Queue, Queues}
  require Logger

  @type queue_name :: atom()
  @type task :: {atom, [arg :: term]}
  @type async_opt :: {:reply, true} | {:delay_secs, pos_integer()}
  @type queue_opts :: map()
  @doc """
  Starts a queue with the given name and workers.

  opts is of type map and can take the following keys:
    * `num` — number of workers to spawn with queue
  """
  @spec start(queue_name, queue_opts()) :: {:ok, pid} | {:error, term()}
  def start(queue_name, opts \\ %{}) do
    queue_opts = Map.put_new(opts, :name, queue_name)
    with {:ok, pid} <- Queues.start_queue(queue_opts)
      do
        Logger.info("Started Queue #{inspect queue_name} at #{inspect(pid)}")
      else
        {:error, reason} ->
          Logger.error("Failed to start queue with name #{queue_name}. Reason: #{inspect reason}")
      end
  end

  @spec async(task, queue_name, [async_opt]) :: Job.t | no_return
  def async(task, queue, opts \\ []) do
    queue_pid = Zucchini.Registry.whereis_name({:queue, queue})
    job = Job.new(task, queue, queue_pid, self())
    |> enqueue
  end



  def enqueue(%Job{queue: queue} = job) do
    queue
    |> Registry.exists?
    |> case do
      true -> queue
      false -> raise RuntimeError, no_queue_error(job)
    end
    |> Queue.enqueue(job)
  end



  @doc false
  def no_queue_error(%Job{queue: _queue_name = queue} = job) do
    "`unable to to find queue: #{inspect queue}, cannot enqueue job #{inspect job}"
  end

end
