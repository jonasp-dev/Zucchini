defmodule Zucchini.WorkerSupervisor do

    alias Zucchini.Worker
    alias Zucchini.WorkerCache
    use DynamicSupervisor
    
    def start_link(%{name: name, num: num, worker_cache: worker_cache} = init_arg) do
        {:ok, supervisor} = DynamicSupervisor.start_link(__MODULE__, init_arg, name: name)

        Enum.each(1..num, fn _ ->

           {:ok, pid} = start_worker([supervisor] ++ [init_arg])
            WorkerCache.checkin(worker_cache, pid)
        end
        )
        {:ok, supervisor}
    end
    
      @impl true
      def init(init_arg) do
        DynamicSupervisor.init(strategy: :one_for_one)
      end


      def start_worker([supervisor | rest] = opts) do
          child_spec = Worker.child_spec(opts)
          {:ok, pid} = DynamicSupervisor.start_child(supervisor, child_spec)
      end


end