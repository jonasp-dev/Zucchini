defmodule Zucchini.Job do
    require Logger
    # :task - task to be done
    # :queue - queue job belongs to
    # :enqueued_at - time job was enqueued at
    # :from - process that requested the job, incase a reply is needed
    # :result - the result of running the task
    # :job_monitor - monitor for the job incase it fails
    # :start_at - the time the job began being ran
    # :completed_at - the time the job finished
    defstruct [ :task,
                :queue,
                :queue_pid,
                :enqueued_at,
                :from,
                :result,
                :worker,
                :job_monitor,
                :started_at,
                :completed_at]


    def new(job = %__MODULE__{}, opts, queue, queue_pid) do
        %__MODULE__{ job | queue: queue, queue_pid: queue_pid, enqueued_at: System.system_time(:millisecond)}
    end

    defp new(module, function, args) do
        %__MODULE__{task: {module, function, args}}
    end

    @doc """
    Creates a Job struct containing the appropriate task keyword for the passed in module, function, args

    create_job/2 takes in a function and args,

    ## Parameters

  """

    def create_job(function, args) when is_list(args) do
        [module: module, name: name, arity: _arity, env: _, type: _] = Function.info function
        create_job(module, name, args)
    end

    def create_job(module, function, args) when is_list(args) do
        case verify_task(module, function, length(args)) do
            true ->
                new(module, function, args)
            false ->
                Logger.error("Failed to create job: #{inspect module} #{inspect function} with arity #{inspect length(args)} either does not exist or is not public")
                :error
        end
    end

    def verify_task(module, function, arity) do
       Keyword.get_values(module.__info__(:functions), function)
       |> Enum.member?(arity)
       |> case do
        true ->
            true
        false ->
            false
       end

    end
end
