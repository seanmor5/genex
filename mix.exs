defmodule Genex.MixProject do
  use Mix.Project

  def project do
    [
      app: :genex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Genex",
      source_url: "http://www.github.com/seanmor5/genex"
    ]
  end

  def application do
    [
      extra_applications: [:table_rex]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:table_rex, "~> 2.0.0"}
    ]
  end

  defp description do
    "Genex makes it easy to write Genetic Algorithms in Elixir."
  end

  defp package do
    [
      name: "genex",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "http://www.github.com/seanmor5/genex"}
    ]
  end
end
