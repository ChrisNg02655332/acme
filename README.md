# Acme

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `acme` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:acme, git: "https://github.com/ChrisNg02655332/acme.git", tags: "0.1.0", branch: "stable" }
  ]
end
```

## Setup

Modify your config/config.ex file

```elixir
config :acme, repo: MyApp.Repo 
```

After the packages are installed you must create a database migration to add the oban_jobs table to your database:

```elixir
mix ecto.gen.migration add_acme_jobs_table
```

Open the generated migration in your editor and call the up and down functions on Acme.Migration:

```elixir
defmodule MyApp.Repo.Migrations.AddAcmeJobsTable do
  use Ecto.Migration

  def up do
    Acme.Migrations.up()
  end

  def down do
    Acme.Migrations.down()
  end
end
```

## Usage

Create example file to add cron job

```elixir
defmodule MyAppWeb.Example do
  def inspect_test(args) do
    IO.inspect(args)
    IO.inspect("Job excuted at #{DateTime.utc_now()}")
  end
end

defmodule MyAppWeb.CronJob do
  def new_job(name) do
    %{params: 1, params: 2}
    |> Acme.perform(name, "* * * * * *", {"MyAppWeb.Example", "inspect_test"})
  end
end
```


