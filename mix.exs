defmodule Msg.MixProject do
  use Mix.Project

  def project do
    [
      app: :msg,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Msg.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:easy_ssl, "~> 1.1.1"},
      {:ex_doc, "~> 0.22.2"},
      {:protobuf, "~> 0.7.1"}
      #{:varint, "~> 1.3"}
    ]
  end
end
