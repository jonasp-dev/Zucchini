defmodule Zucchini.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  alias Zucchini.{Queues, Registry}
  use Application

  
  @impl true
  def start(_type, _args) do
    children = [
      {Queues, []},
      {Registry, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zucchini.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
