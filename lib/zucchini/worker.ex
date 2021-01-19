defmodule Zucchini.Worker do
    use GenServer

    @type private :: term

    @callback init(args :: term) :: {:ok, state :: private}

    defmodule State do
        defstruct [
            :queue,
            :queue_pid,
            :module,
            :init_args,
            :start_opts,
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