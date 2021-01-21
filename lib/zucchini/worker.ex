defmodule Zucchini.Worker do
    use GenServer

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
            :module,
            {:ready, false}
        ] 
    end
    def start_link(opts) do
        GenServer.start_link(__MODULE__, opts)
    end

    @impl true
    def init([queue, queue_pid] = start_args) do
        #Add worker to registry group

        
        {:ok, %State{queue: queue,
                    queue_pid: queue_pid}}
    end



end