defmodule Acme do
  import Crontab.CronExpression.Parser, only: [parse!: 2]
  import Crontab.Scheduler

  @moduledoc """
  Documentation for `Acme`.
  """

  @doc """
  Acme perform.

  The second field can only be used in extended Cron expressions.
  opts = [extended: true]

  ## Examples

      iex> Acme.perform(args, :name, "* * * * * *", cb, opts \\ [])
      :ok

  """

  def perform(args, name, schedule, {module, task}, opts \\ []) do
    if(is_atom(name) == false) do
      raise "Job name should be atom"
    end

    exist =
      list_job()
      |> Enum.find(fn {job_name, _} -> job_name == name end)

    attrs = %{schedule: schedule, module: module, task: task, args: args, state: :active}

    if exist do
      Acme.Scheduler.delete_job(name)
    end

    Acme.Scheduler.new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_schedule(parse!(schedule, opts[:extended] || false))
    |> Quantum.Job.set_task({String.to_atom("Elixir." <> module), String.to_atom(task), [args]})
    |> Acme.Scheduler.add_job()

    if exist == nil do
      Acme.AcmeJobs.insert(Map.put_new(attrs, :name, to_string(name)))
    else
      Acme.AcmeJobs.update(to_string(name), attrs)
    end
  end

  def list_job(), do: Acme.Scheduler.jobs()

  def find_job(name) when is_atom(name), do: Acme.Scheduler.find_job(name)
  def find_job(_), do: raise("Job name should be atom")

  def remove_job(name) when is_atom(name) do
    Acme.Scheduler.delete_job(name)
    Acme.AcmeJobs.delete(to_string(name))
  end

  def remove_job(_), do: raise("Job name should be atom")

  def activate_job(name) when is_atom(name) do
    Acme.Scheduler.activate_job(name)
    Acme.AcmeJobs.update(to_string(name), %{state: :active})
  end

  def activate_job(_), do: raise("Job name should be atom")

  def deactivate_job(name) when is_atom(name) do
    Acme.Scheduler.deactivate_job(name)
    Acme.AcmeJobs.update(to_string(name), %{state: :deactive})
  end

  def deactivate_job(_), do: raise("Job name should be atom")

  def get_next_run_dates(cron_job, date, take \\ 10),
    do: Enum.take(get_next_run_date(cron_job, date), take)

  def get_next_run_dates!(cron_job, date, take \\ 10),
    do: Enum.take(get_next_run_date!(cron_job, date), take)
end
