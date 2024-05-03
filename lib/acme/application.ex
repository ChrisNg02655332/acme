defmodule Acme.Application do
  use Application
  import Acme.Config

  @impl true
  def start(_type, _args) do
    children = if resolve(:init_scheduler, true), do: [Acme.Scheduler], else: []
    Supervisor.start_link(children, strategy: :one_for_one, name: Acme.Supervisor)
  end
end
