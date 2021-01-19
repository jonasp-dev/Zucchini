defmodule Zucchini.Consumer do
    use GenServer

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: :consumer)
    end


    def read_job(queue_name) do
        GenServer.call(:consumer, {:read_job, queue_name})
    end

    @impl true
    def init(_arg) do
        {:ok, {}}
    end

    @impl true
    def handle_call({:read_job, queue_name}, _from, state) do
       response = Zucchini.Queue.dequeue(queue_name)
        {:reply, response, state}
    end
end