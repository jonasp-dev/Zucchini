defmodule Zucchini.Job do
    
    defstruct [:task, 
    :queue,
    :enqueued_at]

    @type t :: %__MODULE__{
        task: Zucchini.task | nil,
        queue: Zucchini.queue_name
    }

    def new(task, queue) do
        %__MODULE__{task: task, queue: queue, enqueued_at: System.system_time(:millisecond)}
    end
end