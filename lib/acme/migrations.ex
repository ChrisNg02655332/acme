defmodule Acme.Migrations do
  use Ecto.Migration

  def up(opts \\ []) do
    create_if_not_exists table(:acme_jobs, primary_key: false, prefix: opts[:prefix] || "public") do
      add(:name, :string, null: false, primary_key: true)
      add(:schedule, :string, null: false)
      add(:state, :string, null: false)
      add(:args, :map, default: "{}")
      add(:module, :string, null: false)
      add(:task, :string, null: false)

      timestamps(type: :utc_datetime)
    end

    create(index(:acme_jobs, [:name], unique: true))
  end

  def down(opts \\ []) do
    drop_if_exists(table(:acme_jobs, prefix: opts[:prefix] || "public"))
  end
end
