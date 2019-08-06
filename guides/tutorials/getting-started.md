# Getting Started

## Install Genex

Genex requires Elixir v1.9. To install Genex, simply add it to your `mix.exs`:

```
def deps do
    [
        # ...
        {:genex, "~> 0.1.0"}
    ]
end
```

## Create Implementation Module

Genex requires an implementation module. The implementation module requires 3 functions: `encoding/0`, `fitness_function/1`, and `terminate?/1`.

Consider the implementation module below:

```
defmodule OneMax do
    use Genex

    def encoding, do: for _  <- 1..15, do: Enum.random(0..1)

    def fitness_function(c), do: Enum.sum(c.genes)

    def terminate?(p), do: p.max_fitness >= 15
end
```

The module we just defined is an implementation of the "One Max" problem. The One Max Problem is a very basic application of Genetic Algorithms in which we attempt to maximize the number of 1's in a list of 1's and 0's.

The problem itself is trivial; however, it provides a good introduction to Genetic Algorithms.

Let's take a closer look at the module, line-by-line.

### `use Genex`

This is how we tell Elixir we want to implement a Genetic Algorithm using Genex. We didn't include any configuration options. This tells Genex we want to use the defaults.

Please see the [configuration](https://hexdocs.pm/genex/0.1.1/introduction-configuration.html) guide for a list of options and defaults.

### Encoding

```
def encoding, do: for _ <- 1..15, do: Enum.random(0..1)
```
Before the algorithm starts, Genex will generate a "seed" population for us. To do so, it needs an encoding of a solution to your problem. This encoding can be ANYTHING as long as it implements the `Enumerable` protocol.

For the purposes of our algorithm, we encode our solutions as a `List` of 1's and 0's. The list has length 15.

### Fitness Function

```
def fitness_function(c), do: Enum.sum(c.genes)
```

We now need to tell Genex how to evaluate our solutions. This is where the fitness function comes into play.

A fitness function takes a Chromosome and assigns some value to it. Conventionally, higher fitness means a "stronger" solution. Usually, we want to maximize fitness.

In our case, the fitness is just the sum of the genes. This effectively counts the number of 1's in the list.

### Termination Criteria

```
def terminate?(p), do: p.max_fitness >= 15
```

Finally, Genex needs to know when to stop the algorithm. We define a termination criteria based on some characteristic in the population.

For our purposes, we've told Genex to terminate the program when the population has reached a max_fitness of 15.

Some algorithms need to terminate after a number of generations. This is possible as well. The `Population` struct exposes a bunch of useful information about the algorithm.

## Running Our Algorithm

Now that we've defined our implementation module, there are a number of ways to run the algorithm.

### In a Script

This is often the easiest solution. With your module defined in a mix project, create a `.exs` file and insert the following line:

```
OneMax.run()
```

Then, in the console:
```
mix run path/to/script.exs
```

You should see the algorithm running with a summary of the current population. It's best to run the algorithms full screen, as right now the visualizers can be problematic.

### Using IEX

Again with your module defined in a mix project, type the following into the console:

```
iex -S mix
```

When IEX loads, run the following:

```
iex> OneMax.run()
```

You'll notice that a struct is returned. That's because `run/0` returns the solution population. The solution population contains the final generation population that was produced before your termination criteria was met.

## Visualizers

Genex contains a text-visualization model to view summaries of Populations. To view a summary of the population returned from the `run/0` function, use:

```
soln = OneMax.run()
Genex.Visualizers.Text.display_summary(soln)
```

This summary will show an overview of the population. Additionally, `IO.inspect` can come in handy when analyzing your algorithm.

## Issues

Please report any issues on the [http://www.github.com/seanmor5/genex](genex) Github page.