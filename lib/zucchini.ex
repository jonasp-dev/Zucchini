defmodule Zucchini do
  alias Zucchini.{Job, Registry, Queue, Queues}

  @type queue_name :: String.t | atom | {:global, String.t | atom}
  @type task :: {atom, [arg :: term]}
  @type async_opt :: {:reply, true} | {:delay_secs, pos_integer()}

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
  def no_queue_error(%Job{queue: {:queue, _} = queue} = job) do
    "`unable to to find queue: #{inspect queue}, cannot enqueue job #{inspect job}"
  end

  defdelegate start_queue(args), to: Queues
end
