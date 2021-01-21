defmodule Zucchini.JobRunner do
    use GenServer

    defmodule State do
        defstruct [:worker, :job, :module]
    end

    @doc false
    def start_link(opts) do
        GenServer.start_link(__MODULE__, opts)
    end

    # def run_link(f, private_args) do
       
    # end
    @impl true
    def init([worker, job, module]) do
        {:ok, %State{
            job: job,
            module: module,
            worker: worker
        }, {:continue, :run}}
    end

    # defp run_job(%State{job: %Job{task: task} = job,
    #             module: module,
    #             worker: worker} = state) do
    #     result = 
    #         case task do
    #             f when is_function(f) -> apply(f, private_args)
    #             f when is_atom(f)     -> apply(module, f, private_args)
    #             {f, a}                -> apply(module, f, a ++ private_args)
    #         end    
    #     {:ok, result}
    # end


    def handle_continue(:run, state) do
        state = run_job(state)
        {:stop, :normal, state}
    end

end