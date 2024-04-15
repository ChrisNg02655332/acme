defmodule Acme.MixProject do
  use Mix.Project

  def project do
    [
      app: :acme,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Acme.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quantum, "~> 3.0"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
