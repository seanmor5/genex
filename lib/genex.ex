defmodule Genex do
  alias Genex.Types.{Chromosome, Population}

  @moduledoc """
  Genex makes it easy to write Evolutionary Algorithms in Elixir.
  The process of creating an algorithm in Genex can be thought of in three phases:
    1. Problem Definition
    2. Evolution Definition
    3. Algorithm Execution
  The `Genex` module contains the behaviour necessary to encode a problem the *Genex Way*. This module implements "Phase 1" of the three phase process used by Genex.
  Genex problems consist of a minimum of 3 and at most 6 functions. These functions:
    1. Define your solution space (`genotype/0` and `datatype/0`).
    2. Define your objective function (`fitness_function/1` and `weights/0`).
    3. Define your termination criteria (`terminate?/1`).
  ## Implementing a Problem
  A basic Genex problem consists of: `genotype/0`, `fitness_function/1`, and `terminate?/1`. To define your first problem, create a new module with `use Genex` and declare each of these functions:
  ```
  defmodule MyProblem do
    use Genex
    def genotype, do: Genotype.binary(10)
    def fitness_function(chromosome), do: Enum.sum(chromosome.genes)
    def terminate?(population), do: population.max_fitness == 10
  end
  ```
  ## Running a Problem
  Genex injects a special function called `run/1` into your problem definition. `run/1` takes a number of optional configuration options you can use to change how your algorithm is executed (*see configuration guide*). To properly run your algorithm, open up `iex` and call `MyProblem.run()` or declare your module in `.exs` file and run `mix run path/to/my_problem.exs`.
  ## Configuring Algorithms
  Genex supports the following configuration options:
    - `:title`: `String` title of your algorithm. Defaults to `"Genetic Algorithm"`.
    - `:population_size`: `Integer` size of your initial population.
    - `:selection_type`: `Function` selection strategy. Defaults to `Genex.Selection.natural()`.
    - `:crossover_type`: `Function` crossover strategy. Defualts to `Genex.Crossover.single_point()`.
    - `:mutation_type`: `Function` mutation strategy. Defaults to `:none`.
    - `:survival_selection_type`: `Function` survival selection strategy. Defaults to `Genex.Selection.natural()`.
    - `:selection_rate`: `Float` between `0` and `1` or `Function`. Defaults to `0.8`.
    - `:mutation_rate`: `Float` between `0` and `1` or `Function`. Defaults to `0.05`.
    - `:survival_rate`: `Float` between `0` and `1` or `Function`. Defaults to `1 - selection_rate`.
  All of these options are passed to `run/1` as a `Keyword` list. See *Configuring Genex* for more.
  ## Additional Utilities
  The problem definition contains a few additional utilities that you might find useful to use. To find out more, see *Additional Utilities*.
  """

  @doc """
  Generates a random gene set.
  This function is called `n` times, where `n` is the size of your population, at the beginning of the genetic algorithm to define the initial population. It's important that this function return random values, otherwise your initial population will consist of entirely the same set of solutions.
  The genotype of your problem represents how solutions to problems are encoded. It's your solution space. `Genex.Tools.Genotype` implements several convenience functions for representing different types of solutions. See the *Representing Solutions* guide for information about the different ways to represent solutions with Genex.
  """
  @callback genotype :: Enum.t()

  @doc """
  Function used to specify how genes are stored in the chromosome.
  Genex supports any structure that implements `Enumerable`. After each generation, the algorithm "repairs" broke chromosomes by calling `collection` on each chromosome in the population. This is because many of the functions in `Enum` explicitly return a `List`.
  This should be a reference to a function that accepts an `Enum` and returns an `Enum`. Most data structures come with a utility function for creating new versions from other types. An example is `MapSet.new/1`. Elixir's `MapSet.new/1` accepts an `Enum` and returns a new `MapSet`.
  The default version of this function returns a function that returns itself. In other words, the default version of this function simply returns the current representation of the chromosome. Because of how some of the functions in `Enum` work, this will always be a `List`.
  """
  @callback collection :: (Enum.t() -> Enum.t())

  @doc """
  Evaluates a chromosome.
  The fitness function is your objective function(s). It is the function(s) you are trying to optimize. The fitness function will be used during an evolution to evaluate solutions against one another.
  Genex supports multiple objectives. You can optimize multiple objectives at once by returning an `Enum` of objectives calculated from the chromosome.
  It's important to note that `chromosome` is of type `Chromosome.t`. Typically you want to assess fitness based on the genes of the chromosome, so you must access the `genes` field of the struct.
  """
  @callback fitness_function(chromosome :: Chromosome.t()) :: number() | Enum.t()

  @doc """
  Returns initial weights associated with each objective.
  The weights associated with each objective represent how "important" each weight is to your final solution. Typically, you want to weigh objectives equally, so your weights will consist of all ones.
  The default implementation of this function returns `1`. This represents a single objective maximization problem. To minimize the objective function, declare a weight of `-1`. You can also achieve this in the fitness function; however, declaring weights makes your algorithm more expressive and easier to follow.
  """
  @callback weights :: number() | Enum.t()

  @doc """
  Tests the population for some termination criteria.
  The termination criteria is assessed at the beginning of every generation. If termination criteria is met, the algorithm halts and returns the current population.
  Termination criteria assesses the entire population. The `Population` struct contains several convenience features you can use to determine when to halt your algorithms. You can stop on max fitness, generations, or some arbitrary feature determined from the population. Check out *Crafting Termination Criteria* to see more.
  """
  @callback terminate?(population :: Population.t()) :: boolean()

  defmacro __using__(_) do
    quote do
      @behaviour Genex
      alias Genex.Types.Chromosome
      alias Genex.Types.Population
      alias Genex.Tools.{Benchmarks, Evaluation, Genotype}

      def collection, do: & &1

      def weights, do: 1

      def eval(c), do: c.fitness

      @spec seed(Keyword.t()) :: {:ok, Enum.t(Chromosome.t())}
      defp seed(opts \\ []) do
        size = Keyword.get(opts, :population_size, 100)
        fun = &genotype/0

        chromosomes =
          fun
          |> Stream.repeatedly()
          |> Stream.map(fn g -> collection().(g) end)
          |> Stream.map(fn g ->
            %Chromosome{
              genes: g,
              size: Enum.count(g),
              weights: weights(),
              f: &fitness_function/1,
              collection: &collection/0
            }
          end)
          |> Enum.take(size)

        pop = %Population{chromosomes: chromosomes, size: Enum.count(chromosomes)}
        {:ok, pop}
      end

      @spec run(Keyword.t()) :: Population.t()
      def run(opts \\ []) do
        evolution = Keyword.get(opts, :evolution, Genex.Evolution.Simple)

        with {:ok, population} <- seed(opts),
             {:ok, population} <- evolution.init(population, opts),
             {:ok, population} <- evolution.evaluation(population, opts),
             {:ok, population} <-
               evolution.evolve(population, &terminate?/1, opts) do
          evolution.termination(population, opts)
        else
          err -> raise err
        end
      end

      @spec profile :: :ok
      def profile(opts \\ []), do: :ok

      defp valid_opts?(opts \\ []), do: :ok

      defoverridable profile: 1, weights: 0, collection: 0
    end
  end
end