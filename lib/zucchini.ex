defmodule Zucchini do
  @moduledoc """
  Documentation for `Zucchini`.

  defmodule MyWorker do
  def do_a_thing do
    IO.puts "doing a thing!"
  end
end

:ok = Zucchini.start_queue(:my_queue)
:ok = Zucchini.start_workers(:my_queue, MyWorker)

:do_a_thing |> Zucchini.async(:my_queue)

# => "doing a thing!"
  """

  alias Zucchini.{Job, Registry, Queue, Queues}

  @type queue_name :: String.t | atom | {:global, String.t | atom}
  @type task :: {atom, [arg :: term]}
  @type async_opt :: {:reply, true} | {:delay_secs, pos_integer()}

  @spec async(task, queue_name, [async_opt]) :: Job.t | no_return
  def async(task, queue, opts \\ []) do
    job = Job.new(task, queue)

     job = 
      opts
      |> Enum.reduce(job, fn
        {:reply, true}, job ->
          %Job{job | from: {self(), make_ref()}} 
        end)
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
  def invalid_delay_secs_error(job, secs) do
    "invalid :delay_secs argument, #{inspect secs}, provided for job #{inspect job}, must be a non-negative integer"
  end

  @doc false
  def no_queue_error(%Job{queue: {:queue, _} = queue} = job) do
    "can't enqueue job because there aren't any queue processes running for the distributed queue `#{inspect queue}, are you connected to the cluster? #{inspect job} `"
  end

  defdelegate start_queue(name), to: Queues
end
