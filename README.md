# Genex

> Genex makes it easy to write Evolutionary Algorithms with Elixir.

[![Build Status](https://travis-ci.org/seanmor5/genex.svg?branch=master)](https://travis-ci.org/seanmor5/genex)
[![Coverage Status](https://coveralls.io/repos/github/seanmor5/genex/badge.svg?branch=master)](https://coveralls.io/github/seanmor5/genex?branch=master)
[![Hex Version](https://img.shields.io/hexpm/v/genex)](https://hex.pm/packages/genex/0.1.4)

This library is inspired by Python's [DEAP](https://github.com/deap/deap).

## Documentation

Documentation is available at [https://hexdocs.pm/genex/introduction-overview.html](https://hexdocs.pm/genex/introduction-overview.html)

## Installation

The package can be installed by adding `genex` to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:genex, "~> 0.2.1"}
  ]
end
```

## Usage

Genex requires an implementation module with 3 functions: `encoding/0`, `fitness_function/1`, and `terminate?/1`.

```elixir
defmodule OneMax do
  use Genex

  def encoding do
    for _ <- 1..10, do: Enum.random(0..1)
  end

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

- 6 Selection Operators
- 7 Crossover Operators
- 6 Mutation Operators
- Customizable Population Statistics
- Customizable Benchmarking of Algorithms
- Exportable Genealogy Tree
- Flexible Encoding of Chromosomes
- Simple Text Visualizations

## Examples

There are currently 3 basic examples available in the `examples` directory. To run them, clone the repo and run:

```
mix run examples/[example].exs
```

The current examples are:

- `one_max.exs`
- `speller.exs`
- `linear_regression.exs`
- `n_queens.exs`

## Benchmarks

To run benchmarks, clone this repo. In the `genex` directory run:

```
mix run bench/benchmarks.exs
```

You can also run the individual benchmarks available in the `bench/` directory. This will take some time!

## Contributing

If you have any problems with Genex, please open an issue! If you have a fix for an issue, submit a pull request.

## Roadmap

The next phase of this library will involve extensive performance improvements. Most of the algorithms involve processing very large lists. This is an ideal job for a NIF.

If anybody has any experience writing NIFs or writing algorithms for processing large lists, [email me](mailto:smoriarity.5@gmail.com) to get involved!