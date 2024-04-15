defmodule Acme.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [Acme.Scheduler]
    Supervisor.start_link(children, strategy: :one_for_one, name: Acme.Supervisor)
  end
end
