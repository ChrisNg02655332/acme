defmodule Acme.Scheduler do
  use Quantum, otp_app: :acme

  alias Ecto.Repo
  alias Acme.AcmeJobs

  import Crontab.CronExpression.Parser, only: [parse!: 2]

  def init(opts) do
    Task.start(fn -> prepare_jobs() end)
    opts
  end

  defp prepare_jobs() do
    if Repo.all_running() |> Enum.member?(Acme.Config.resolve(:repo)) == false do
      Process.sleep(1_000)
      prepare_jobs()
    else
      delete_all_jobs()

      AcmeJobs.list()
      |> Enum.each(fn p ->
        Acme.Scheduler.new_job()
        |> Quantum.Job.set_name(String.to_atom(p.name))
        |> Quantum.Job.set_schedule(parse!(p.schedule, false))
        |> Quantum.Job.set_task(
          {String.to_existing_atom("Elixir." <> p.module), String.to_atom(p.task), [p.args]}
        )
        |> Acme.Scheduler.add_job()
      end)
    end
  end
end
