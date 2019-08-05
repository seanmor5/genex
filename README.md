# Genex

> Genex makes it easy to write Genetic Algorithms with Elixir.

[![Build Status](https://travis-ci.org/seanmor5/genex.svg?branch=master)](https://travis-ci.org/seanmor5/genex)
[![Coverage Status](https://coveralls.io/repos/github/seanmor5/genex/badge.svg?branch=master)](https://coveralls.io/github/seanmor5/genex?branch=master)

This library is inspired by Python's [DEAP](https://github.com/deap/deap).

## Installation

The package can be installed by adding `genex` to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:genex, "~> 0.1.0"}
  ]
end
```

## Usage

Genex works by making transformations on a `Population`.

The simplest way to use Genex is by including it in one of your modules with default parameters.

It requires you to implement 3 functions: `encoding/0`, `fitness_function/1`, `terminate?/1`.

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

Your algorithm can then be run by calling the `run/0` method Genex provides.

## Visualization

Genex currently offers text visualization of populations. To view a summary of the solution your algorithm produced simply do:
```elixir
soln = OneMax.run()
Genex.Visualizers.Text.display_summary(soln)
```

## Genealogy

Genex comes with an implementation of a Genealogy tree using an Erlang digraph. The tree is available in the `history` field of the `Population` struct. As of this version of Genex, there are no pre-packaged genealogy visualizers. You'll have to find a third-party solution.

## Configuration

Genex can be configured like so:
```elixir
def MyGA do
    use Genex, crossover_type: :two_point, crossover_rate: 0.5
    ...
end
```

Please see the [documentation](https://hexdocs.pm/genex/Genex.html) for a full list of configuration options.

## Task List
- [ ] Crossover
    - [x] Single Point
    - [x] Two Point
    - [x] Uniform
    - [ ] Davis Order
    - [ ] Partially Matched
    - [x] Blend
    - [ ] Simulated Binary
    - [ ] Uniform Partially Matched
    - [ ] Messy One Point
    - [ ] ES Blend
- [ ] Mutation
    - [x] Bit Flip
    - [ ] Uniform Integer
    - [ ] Gaussian
    - [x] Shuffle
    - [x] Invert
    - [ ] Polynomial Bounded
    - [ ] ES Log Normal
- [ ] Selection
    - [x] Natural Selection
    - [x] Random Selection
    - [x] Worst Selection
    - [ ] Roulette Selection
    - [ ] Tournament Selection
    - [ ] Stochastic Universal Sampling
    - [ ] Double Tournament Selection
    - [ ] Lexicase
    - [ ] Epsilon Lexicase
    - [ ] Automatic Epsilon Lexicase