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

It requires you implement 3 functions: `chromosome`, `fitness_function`, `goal_test`. 

```elixir
defmodule MyGeneticAlgorithm do
    use Genex

    def init(_opts) do
    end

    def fitness_function(chromosome) do
        Enum.sum(chromosome)
    end

    def goal_test(population) do
        population.max_fitness == 32
    end
end
```
