# Genex

Genex makes it easy to write Genetic Algorithms with Elixir.

This library is inspired by Python's [DEAP](https://github.com/deap/deap).

## Installation

If the package can be installed by adding `genex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:genex, "~> 0.1.0"}
  ]
end
```

## Usage

Genex works by making transformations on a `Population`. A `Population` is a struct with some parameters the algorithm uses.

The simplest way to use Genex is by including it in one of your modules with default parameters.

It requires you to implement 3 functions: `chromosome`, `fitness_function`, `goal_test`. 

```elixir
defmodule OneMax do
  use Genex

  def chromosome do
    for _ <- 1..20, do: Enum.random(0..1)
  end

  def fitness_function(genes), do: Enum.sum(genes)

  def goal_test(population), do: population.max_fitness == 20
end

OneMax.run()
```

## Task List
- [ ] Crossover
    - [x] Single Point
    - [ ] Multi Point
    - [x] Uniform
    - [ ] Davis Order
    - [ ] Whole Arithmetic
- [ ] Mutation
    - [x] Bit Flip
    - [ ] Uniform Integer
    - [ ] Gaussian
    - [ ] Scramble
    - [x] Shuffle Indexes
    - [x] Invert
- [ ] Selection
    - [x] Natural Selection
    - [x] Random Selection
    - [x] Worst Selection
    - [ ] Roulette Selection
    - [ ] Tournament Selection
    - [ ] Stochastic Universal Sampling
- [ ] Support
    - [ ] Hall of Fame
    - [ ] Logbook
    - [ ] History (Geneology Tree)