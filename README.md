# Genex

Genex makes it easy to write Genetic Algorithms with Elixir.

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

Genex works by making transformations on a `Population`. A `Population` is a struct with some parameters the algorithm uses.

The simplest way to use Genex is by including it in one of your modules with default parameters.

It requires you to implement 3 functions: `chromosome`, `fitness_function`, `goal_test`. 

```elixir
defmodule OneMax do
  use Genex

  def individual do
    for _ <- 1..10, do: Enum.random(0..1)
  end

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 10
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
    - [ ] Partially Matched
    - [ ] Blend
    - [ ] Simulated Binary
    - [ ] Uniform Partially Matched
    - [ ] Messy One Point
    - [ ] ES Blend
- [ ] Mutation
    - [x] Bit Flip
    - [ ] Uniform Integer
    - [ ] Gaussian
    - [ ] Scramble
    - [x] Shuffle Indexes
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
- [ ] Support
    - [ ] Hall of Fame
    - [ ] Logbook
    - [ ] History (Geneology Tree)