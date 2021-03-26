defmodule Zucchini.WorkerCache do
    alias Zucchini.Registry

    use Agent
    #cache has the same name as queue that called start_link/1
    def start_link(%{name: cache_name} = opts \\ %{}) do
        Agent.start_link(fn -> %{cache_name: cache_name, cache: {:queue.new, MapSet.new}} end, name: via_tuple(cache_name))
    end

    def available?(pid) do
        %{cache: {free, busy}} = Agent.get(pid, fn state -> state end) 
        !:queue.is_empty(free)
    end

    def checkin(pid, worker) do
       Agent.update(pid, fn %{cache_name: cache_name, cache: {free, busy}} -> %{cache_name: cache_name, cache: {:queue.in(worker, free), MapSet.delete(busy, worker)}} end)
       %{cache_name: cache_name} = Agent.get(pid, fn state -> state end)  
       Zucchini.Queue.worker_finished(cache_name)
    end

    def checkout(pid) do
       %{cache: {free, busy}} = Agent.get(pid, fn state -> state end) 
       case :queue.out(free) do
            {{:value, worker}, freequeue} ->
                Agent.update(pid, fn %{cache_name: cache_name, cache: {free, busy}} -> %{cache_name: cache_name, cache: {freequeue,  MapSet.put(busy, worker)}} end)
                %{cache: {free, busy}} = Agent.get(pid, fn state -> state end) 
                {worker, {free, busy}}
            {:empty, _free} ->
                {:error, nil, {free, busy}}
       end
    end

    defp via_tuple(cache_name) do
        {:via, Zucchini.Registry, {:worker_cache, cache_name}}
    end
end