defmodule Zucchini.Job do
    
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

    @type t :: %__MODULE__{
        task: Zucchini.task | nil,
        queue: Zucchini.queue_name
    }

    def new(task, queue, queue_pid, from) do
        %__MODULE__{task: task, queue: queue, queue_pid: queue_pid, enqueued_at: System.system_time(:millisecond), from: from}
    end
end