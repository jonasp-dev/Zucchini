defmodule Zucchini.Job do
    
    defstruct [ :task, 
                :queue,
                :enqueued_at,
                :from,
                :result,
                :by,
                :job_monitor,
                :started_at,
                :completed_at,
                {:delay_secs, 0}]

    @type t :: %__MODULE__{
        task: Zucchini.task | nil,
        queue: Zucchini.queue_name,
        delay_secs: integer()
    }

    def new(task, queue) do
        %__MODULE__{task: task, queue: queue, enqueued_at: System.system_time(:millisecond)}
    end
end