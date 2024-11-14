defmodule DetectiveGame.MixProject do
  use Mix.Project

  def project do
    [
      app: :detective_game,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def start(_type, _args) do
    Application.ensure_all_started(:faker)

    children = []

    opts = [strategy: :one_for_one, name: YourApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp deps do
    [
      {:faker, "~> 0.18"}
    ]
  end
end
