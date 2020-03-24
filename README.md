# Genex

> Genex makes it easy to write Genetic Algorithms with Elixir.

[![Build Status](https://travis-ci.org/seanmor5/genex.svg?branch=master)](https://travis-ci.org/seanmor5/genex)
[![Coverage Status](https://coveralls.io/repos/github/seanmor5/genex/badge.svg?branch=master)](https://coveralls.io/github/seanmor5/genex?branch=master)
[![Hex Version](https://img.shields.io/hexpm/v/genex)](https://hex.pm/packages/genex/1.0.0-beta)

This library is inspired by Python's [DEAP](https://github.com/deap/deap).

## Documentation

Documentation is available at [https://hexdocs.pm/genex/index.html](https://hexdocs.pm/genex/introduction-overview.html)

## Installation

The package can be installed by adding `genex` to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:genex, "~> 1.0.0-beta"}
  ]
end
```

## Usage

Genex requires an implementation module with 3 functions: `genotype/0`, `fitness_function/1`, and `terminate?/1`.

```elixir
defmodule OneMax do
  use Genex

  def genotype, do: Genotype.binary(10)

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 10
end
```

Now, run `iex -S mix`.

Then:
```
  iex> OneMax.run()
```

## Features

Genex strives to be as simple and customizable as possible. Along with the ability to customize EVERY step of your Genetic algorithm, Genex comes with the following features:

- 6 Selection Operators (14 anticipated)
- 12 Crossover Operators (17 anticipated)
- 4 Mutation Operators (9 anticipated)
- Fully Customizable Evolutions
- Multi-Objective Optimization
- Penalty Functions
- Genotype Generation Helpers
- Benchmarking of Common Problems
- Exportable Genealogy Tree
- Exportable Hall of Fame
- Flexible Encoding of Chromosomes (any `Enum`)
- Extendable Visualizations

To request a feature, please open an issue.

## Examples

There are currently 5 basic examples available in the `examples` directory. To run them, clone the repo and run:

```
mix run examples/[example].exs
```

The current examples are:

- `one_max.exs`
- `knapsack.exs`
- `speller.exs`
- `tsp.exs`
- `n_queens.exs`
- `knapsack.exs`

## Genex in Practice

These projects use Genex in practice:

- [seanmor5/covid](http://github.com/seanmor5/covid)

To feature yours, please submit a pull request.

## Contributing

If you have any problems with Genex, please open an issue! If you have a fix for an issue, submit a pull request.