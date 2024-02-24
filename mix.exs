defmodule Genex.MixProject do
  use Mix.Project

  @version "1.0.1-beta"
  @url "https://www.github.com/seanmor5/genex"
  @maintainers ["Sean Moriarity"]

  def project do
    [
      name: "Genex",
      app: :genex,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url: @url,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      maintainers: @maintainers,
      homepage_url: @url,
      description: description(),
      docs: docs(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:table_rex]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      extra_section: "guides",
      formatters: ["html", "epub"],
      groups_for_modules: groups_for_modules(),
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    []
  end

  defp groups_for_extras do
    [
      Introduction: Path.wildcard("guides/introduction/*.md"),
      Operators: Path.wildcard("guides/operators/*.md"),
      Evolutions: Path.wildcard("guides/evolutions/*.md"),
      Support: Path.wildcard("guides/support/*.md"),
      Tutorials: Path.wildcard("guides/tutorials/*.md")
    ]
  end

  defp groups_for_modules do
    [
      "Genetic Operators": [
        Genex.Tools.Crossover,
        Genex.Tools.Migration,
        Genex.Tools.Mutation,
        Genex.Tools.Selection
      ],
      "Solution Representations": [
        Genex.Tools.Genotype
      ],
      Evolutions: [
        Genex.Evolution,
        Genex.Evolution.Coevolution,
        Genex.Evolution.GenerateUpdate,
        Genex.Evolution.MuCommaLambda,
        Genex.Evolution.MuPlusLambda,
        Genex.Evolution.Simple
      ],
      Benchmarks: [
        Genex.Tools.Benchmarks.Binary,
        Genex.Tools.Benchmarks.MultiObjectiveContinuous,
        Genex.Tools.Benchmarks.SingleObjectiveContinuous,
        Genex.Tools.Benchmarks.SymbolicRegression
      ],
      "Evaluation Tools": [
        Genex.Tools.Evaluation,
        Genex.Tools.Evaluation.Indicator,
        Genex.Tools.Evaluation.Penalty
      ],
      Support: [
        Genex.Support.Checkpoint,
        Genex.Support.Genealogy,
        Genex.Support.HallOfFame,
        Genex.Support.Logbook
      ],
      Structures: [
        Genex.Types.Chromosome,
        Genex.Types.Community,
        Genex.Types.Population
      ],
      Visualizations: [
        Genex.Visualizer
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:table_rex, "~> 2.0.0"},
      {:benchee, "~> 1.0"},
      {:libgraph, "~> 0.13.0"},
      {:statistics, "~> 0.6.2"}
    ]
  end

  defp description do
    "Genex makes it easy to write Evolutionary Algorithms in Elixir."
  end

  defp package do
    [
      maintainers: @maintainers,
      name: "genex",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "http://www.github.com/seanmor5/genex"}
    ]
  end
end
