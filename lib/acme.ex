defmodule Acme do
  @moduledoc """
  Documentation for `Acme`.
  """
  import Crontab.CronExpression.Parser, only: [parse!: 2]
  import Crontab.Scheduler
  import Acme.Config
  alias Acme.AcmeJobs

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
      insert(Map.put_new(attrs, :name, to_string(name)))
    else
      update(to_string(name), attrs)
    end
  end

  def list_job(), do: Acme.Scheduler.jobs()

  def find_job(name) when is_atom(name), do: Acme.Scheduler.find_job(name)
  def find_job(_), do: raise("Job name should be atom")

  def remove_job(name) when is_atom(name) do
    Acme.Scheduler.delete_job(name)
    delete(to_string(name))
  end

  def remove_job(_), do: raise("Job name should be atom")

  def activate_job(name) when is_atom(name) do
    Acme.Scheduler.activate_job(name)
    update(to_string(name), %{state: :active})
  end

  def activate_job(_), do: raise("Job name should be atom")

  def deactivate_job(name) when is_atom(name) do
    Acme.Scheduler.deactivate_job(name)
    update(to_string(name), %{state: :deactive})
  end

  def deactivate_job(_), do: raise("Job name should be atom")

  @doc """
  Acme perform.

  The second field can only be used in extended Cron expressions.
  opts = [extended: true]

  ## Examples

      iex> Acme.get_next_trigger_dates(:name, opts \\ [])
      {:ok, list}

  """
  def get_next_trigger_dates(name, opts \\ []) do
    with true <- is_atom(name),
         job <- get(to_string(name)) do
      {:ok,
       Enum.take(
         get_next_run_dates(
           parse!(job.schedule, opts[:extended] || false),
           opts[:date] || NaiveDateTime.utc_now()
         ),
         opts[:take] || 10
       )}
    else
      _ -> {:error, :not_found}
    end
  end

  def get_next_trigger_dates!(name, opts \\ []) do
    with true <- is_atom(name),
         job <- get(to_string(name)) do
      Enum.take(
        get_next_run_dates(
          parse!(job.schedule, opts[:extended] || false),
          opts[:date] || NaiveDateTime.utc_now()
        ),
        opts[:take] || 10
      )
    else
      _ -> raise "No job available"
    end
  end

  # CRUD AcmeJobs - DONOT export

  defp get(name) do
    prefix = resolve(:prefix, "public")
    AcmeJobs |> resolve(:repo).get_by!([name: name], prefix: prefix)
  end

  defp insert(attrs) do
    prefix = resolve(:prefix, "public")

    %AcmeJobs{}
    |> AcmeJobs.changeset(attrs)
    |> resolve(:repo).insert(prefix: prefix)
  end

  defp update(name, attrs) do
    prefix = resolve(:prefix, "public")

    AcmeJobs
    |> resolve(:repo).get_by!(name: name)
    |> AcmeJobs.changeset(attrs)
    |> resolve(:repo).update(prefix: prefix)
  end

  defp delete(name) do
    prefix = resolve(:prefix, "public")

    AcmeJobs |> resolve(:repo).get_by!(name: name) |> resolve(:repo).delete(prefix: prefix)
  end
end
