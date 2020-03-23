defmodule Genex do
  alias Genex.Types.{Chromosome, Population}

  @moduledoc """
  Genex makes it easy to write Evolutionary Algorithms in Elixir.

  The process of creating an algorithm in Genex can be thought of in three phases:

    1) Problem Definition
    2) Evolution Definition
    3) Algorithm Execution

  The `Genex` module contains the behaviour necessary to encode a problem the "Genex Way." This module implements "Phase 1" of the three phase process instituted in Genex.
  """

  @doc """
  Generates a random gene set.
  """
  @callback genotype :: Enum.t()

  @doc """
  Indicates the datatype used to encode solutions.
  """
  @callback datatype :: (() -> Enum.t())

  @doc """
  Seeds a population.
  """
  @callback seed(opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Evaluates a chromosome.
  """
  @callback fitness_function(chromosome :: Chromosome.t()) :: number() | Enum.t()

  @doc """
  Weights associated with each objective.
  """
  @callback weights :: number() | Enum.t()

  @doc """
  Tests the population for some termination criteria.
  """
  @callback terminate?(population :: Population.t()) :: boolean()

  defmacro __using__(_) do
    quote do
      @behaviour Genex
      alias Genex.Types.Chromosome
      alias Genex.Types.Population
      alias Genex.Tools.{Benchmarks, Evaluation, Genotype}

      @doc """
      Specifies the datatype.
      """
      def datatype, do: & &1

      def weights, do: 1

      @doc """
      Seed the population with some chromosomes.

      Returns `Enum.t(%Chromosomes{})`.

      # Parameters

        - `opts`: Keyword list of options.
      """
      @spec seed(Keyword.t()) :: {:ok, Enum.t(Chromosome.t())}
      def seed(opts \\ []) do
        size = Keyword.get(opts, :population_size, 100)

        chromosomes =
          for n <- 1..size do
            g = datatype().(genotype())
            c = %Chromosome{genes: g, size: Enum.count(g), weights: weights(), f: &fitness_function/1}
            c
          end

        pop = %Population{chromosomes: chromosomes, size: length(chromosomes)}
        {:ok, pop}
      end

      @doc """
      Run the genetic algorithm.

      This function combines all previous steps and executes the Genetic Algorithm until completion. It will return the solution population which contains relevant information for analysis of your algorithms performance.

      Returns `%Population{...}`.

      # Parameters

        - `opts`: Configuration options.

      # Options

        - `:crossover_type`: `Function`.
        - `:mutation_type`: `Function`.
        - `:selection_type`: `Function`.
        - `:evolution_type`: `Module`.
        - `:survival_type`: `Function`.
        - `:crossover_rate`: `Function` or `Float` between 0 and 1.
        - `:mutation_rate`: `Function` or `Float` between 0 and 1.
        - `:population_size`: `Integer`.
      """
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

      def eval(c), do: c.fitness

      @doc """
      Profile your genetic algorithm.

      This function will profile your genetic algorithm.

      Returns `:ok`.
      """
      @spec profile :: :ok
      def profile(opts \\ []), do: :ok

      defp valid_opts?(opts \\ []), do: :ok

      defoverridable seed: 1, profile: 1, weights: 0, datatype: 0
    end
  end
end
