defmodule Zucchini.Workers do
    use Supervisor

    alias Zucchini.WorkerSupervisor

    def start_link(args) do
        Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    end
    
    @impl true
    def init(_args) do
        Supervisor.init([], strategy: :one_for_one)
    end


    def start_workers(name, worker_cache, module_and_args, worker_opts) do
        {module, args} =
            case module_and_args do
                module when is_atom(module) -> {module, []}
                {module, args} -> {module, args}
            end
        


        opts = %{
            name: name,
            ma: {module, args},
            num: worker_opts[:num] || 10,
            worker_cache: worker_cache
        }

        child_spec = 
            WorkerSupervisor.child_spec(opts)
            |> Map.put(:id, name)

        with {:ok, child} <- Supervisor.start_child(__MODULE__, child_spec) do
            {:ok, child}
        end

    
    end
    
end