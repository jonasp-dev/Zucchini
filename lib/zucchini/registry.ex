defmodule Zucchini.Registry do
    use GenServer

    # API
    def start_link(_arg) do
        GenServer.start_link(__MODULE__, nil, name: :registry)
    end

    def whereis_name(queue_name) do
        GenServer.call(:registry, {:whereis_name, queue_name})
    end

    def register_name(queue_name, pid) do
        GenServer.call(:registry, {:register_name, queue_name, pid})
    end

    def unregister_name(queue_name) do
        GenServer.cast(:registry, {:unregister_name, queue_name})
    end

    def send(queue_name, message) do
        case whereis_name(queue_name) do
            :undefined ->
                {:badarg, {queue_name, message}}
            pid ->
                Kernel.send(pid, message)
                pid
        end
    end

    # SERVER

    def init(_) do
        {:ok, Map.new}
    end

    def handle_call({:whereis_name, queue_name}, _from, state) do
        {:reply, Map.get(state, queue_name, :undefined), state}
    end

    def handle_call({:register_name, queue_name, pid}, _from, state) do
        case Map.get(state, queue_name) do
            nil ->
                Process.monitor(pid)
                {:reply, :yes, Map.put(state, queue_name, pid)}
            _ ->
                {:reply, :no, state}
        end
    end

    def handle_info({:DOWN, _, :process, pid, _}, state) do
        {:noreply, remove_pid(state, pid)}
    end

    def handle_cast({:unregister_name, queue_name}, state) do
        {:noreply, Map.delete(state, queue_name)}
    end

    def remove_pid(state, pid_to_remove) do
        remove = fn {_key, pid} -> pid != pid_to_remove end
        Enum.filter(state, remove) |> Enum.into(%{})
    end

    def exists?(queue_name) do
        whereis_name({:queue, queue_name})
        |> case do
            pid when is_pid(pid) ->
                true
            :undefined ->
                false
        end
    end
end