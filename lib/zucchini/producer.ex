defmodule Zucchini.Producer do
    use GenServer
    
    @type job :: Job.t

    defmodule Message do
        defstruct [
            :date_time,
            :content
        ]

        def new(message_content) do
            %__MODULE__{content: message_content, date_time: System.system_time(:millisecond)}
        end
    end

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: :producer)
    end

    @spec write_job(pid(), job) :: :ok | :error
    def write_job(queue_name, job) do
        GenServer.cast(:producer, {:write_job, {queue_name, job}})
    end

    def start_queue do
        Zucchini.Queue.start_link("PingPong", %Zucchini.Producer.Message{})
    end

    @impl true
    def init(_arg) do
        start_queue()
        {:ok, {}}
    end

    @impl true
    def handle_cast({:write_job, {queue_name, job}}, state) do
       Zucchini.Queue.enqueue(queue_name, job)
        {:noreply, state}
    end
end