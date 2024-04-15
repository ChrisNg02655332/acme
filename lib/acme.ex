defmodule Acme do
  import Crontab.CronExpression.Parser, only: [parse!: 2]

  @moduledoc """
  Documentation for `Acme`.
  """

  @doc """
  Acme perform.

  ## Examples

      iex> Acme.perform(:name, "* * * * * *", cb, args)
      :ok

  """
  def perform(args, name, schedule, {module, task})
      when is_atom(name) do
    exist =
      list_job()
      |> Enum.find(fn {job_name, _} -> job_name == name end)

    attrs = %{schedule: schedule, module: module, task: task, args: args, state: :active}

    if exist do
      Acme.Scheduler.delete_job(name)
    end

    Acme.Scheduler.new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_schedule(parse!(schedule, false))
    |> Quantum.Job.set_task({String.to_atom("Elixir." <> module), String.to_atom(task), [args]})
    |> Acme.Scheduler.add_job()

    if exist == nil do
      Acme.AcmeJobs.insert(Map.put_new(attrs, :name, to_string(name)))
    else
      Acme.AcmeJobs.update(to_string(name), attrs)
    end
  end

  def perform(_, _, _, _), do: raise("Job name should be atom")

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
end
