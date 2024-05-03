# Acme

**TODO: Add description**

## Installation

The package can be installed by adding `acme` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:acme, git: "https://github.com/ChrisNg02655332/acme.git", tag: "0.1.0" }
  ]
end
```

## Setup

|   opts         |    default   |   type   |
|----------------|:------------:|---------:|
| repo           |  MyApp.Repo  |  module  |
| prefix         |  public      |  string  |
| init_scheduler |  true        |  boolean |


Modify your config/config.ex file

```elixir
config :acme, opts 
```

After the packages are installed you must create a database migration to add the acme_jobs table to your database:

```elixir
mix ecto.gen.migration add_acme_jobs_table
```

Open the generated migration in your editor and call the up and down functions on Acme.Migration:

```elixir
defmodule MyApp.Repo.Migrations.AddAcmeJobsTable do
  use Ecto.Migration

  #IMPORTANT: opts only support prefix and need to add prefix to config
  def up do
    Acme.Migrations.up(opts \\ [])
  end

  def down do
    Acme.Migrations.down(opts \\ [])
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


