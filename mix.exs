defmodule Yams.MixProject do
  use Mix.Project

  def project do
    [
      app: :yams,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Yams.Application, []},
      extra_applications: [:logger, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:easy_ssl, "~> 1.3.0"},
      {:ecto_sql, "~> 3.5"},
      {:ex_doc, "~> 0.22.2"},
      {:myxql, "~> 0.4.5"},
      {:protobuf, "~> 0.7.1"},
      {:uuid, "~> 1.1"}
      #{:varint, "~> 1.3"}
    ]
  end
end
