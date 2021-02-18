defmodule Zucchini.WorkerCache do
    use Agent

    # def start_link(opts) do
    #     GenServer.start_link(__MODULE__, opts)
    # end

    def start_link(_opts) do
        Agent.start_link(fn -> {:queue.new, MapSet.new} end, name: __MODULE__)
    end

    def available?(pid) do
        {free, busy} = Agent.get(pid, fn state -> state end) 
        !:queue.is_empty(free)
    end

    def checkin(pid, worker) do
       Agent.update(pid, fn {free, busy} -> {:queue.in(worker, free), MapSet.delete(busy, worker)} end)
    end

    def checkout(pid) do
       {free, busy} = Agent.get(pid, fn state -> state end) 
       case :queue.out(free) do
            {{:value, worker}, freequeue} ->
                Agent.update(pid, fn {free, busy} -> {freequeue,  MapSet.put(busy, worker)} end)
                {free, busy} = Agent.get(pid, fn state -> state end) 
                {worker, {free, busy}}
            {:empty, _free} ->
                {:error, nil, {free, busy}}
       end
    end

end