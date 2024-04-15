defmodule Acme.AcmeJobs do
  use Ecto.Schema

  import Ecto.Changeset
  import Acme.Config

  @primary_key false
  schema "acme_jobs" do
    field(:name, :string, primary_key: true)
    field(:schedule, :string)
    field(:state, Ecto.Enum, values: [:active, :deactive])
    field(:args, :map)
    field(:module, :string)
    field(:task, :string)

    timestamps(type: :utc_datetime)
  end

  def changeset(acme_job, attrs \\ %{}) do
    acme_job
    |> cast(attrs, [:name, :schedule, :state, :args, :module, :task])
    |> validate_required([:name, :schedule, :module, :task])
    |> unique_constraint(:name)
  end

  def list do
    Acme.AcmeJobs |> resolve(:repo).all()
  end

  def insert(attrs) do
    %Acme.AcmeJobs{}
    |> changeset(attrs)
    |> resolve(:repo).insert()
  end

  def update(name, attrs) do
    Acme.AcmeJobs
    |> resolve(:repo).get_by(name: name)
    |> changeset(attrs)
    |> resolve(:repo).update()
  end

  def delete(name) do
    Acme.AcmeJobs |> resolve(:repo).get_by(name: name) |> resolve(:repo).delete()
  end
end
