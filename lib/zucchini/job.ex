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
                :enqueued_at,
                :from,
                :result,
                :job_monitor,
                :started_at,
                :completed_at]

    @type t :: %__MODULE__{
        task: Zucchini.task | nil,
        queue: Zucchini.queue_name
    }

    def new(task, queue) do
        %__MODULE__{task: task, queue: queue, enqueued_at: System.system_time(:millisecond)}
    end
end