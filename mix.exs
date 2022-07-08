defmodule Axis.MixProject do
  use Mix.Project

  def project do
    [
      app: :axis,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Axis.CLI],
      deps: deps()

      # Docs
      # name: "MyApp",
      # source_url: "https://github.com/USER/PROJECT",
      # homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      # docs: [
      #   # The main page in the docs
      #   main: "MyApp",
      #   logo: "path/to/logo.png",
      #   extras: ["README.md"]
      # ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sshex, "2.2.1"},
      {:jason, "~> 1.3"},
      {:httpoison, "~> 1.8"},
      {:briefly, "~> 0.3"},
      {:optimus, "~> 0.2"},
      {:prompt, "~> 0.8.0"},
      {:progress_bar, "> 0.0.0"},
      {:bamboo, "> 0.0.0"},
      {:bamboo_smtp, "> 0.0.0"},
      {:ex_json_schema, "~> 0.9.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
