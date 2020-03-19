defmodule Genex do
  alias Genex.Types.Chromosome
  alias Genex.Types.Population

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
  @callback fitness_function(chromosome :: Chromosome.t()) :: number()

  @doc """
  Tests the population for some termination criteria.
  """
  @callback terminate?(population :: Population.t()) :: boolean()

  defmacro __using__(_) do
    quote do
      @behaviour Genex
      alias Genex.Types.Chromosome
      alias Genex.Types.Population
      alias Genex.Tools.Genotype
      alias Genex.Tools.Evaluation
      alias Genex.Tools.Benchmarks

      @doc """
      Specifies the datatype.
      """
      def datatype, do: & &1

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
            c = %Chromosome{genes: g, size: Enum.count(g)}
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

        - `:crossover_type`: `Function` or one of: `:single_point`, `:two_point`, `:davis_order`, `:uniform`, `:blend`, `:simulated_binary`, `:messy_single_point`.
        - `:mutation_type`: `Function` or one of: `:bit_flip`, `:scramble`, `:invert`, `:uniform_integer`, `:gaussian`, `:polynomial_bounded`.
        - `:selection_type`: `Function` or one of `:natural`, `:random`, `:worst`, `:tournament`, `:roulette`, `:stochastic`.
        - `:evolution_type`: `Module` or one of `:simple`, `:mu_plus_lambda`, `:mu_comma_lambda`, `:coevolution`.
        - `:crossover_rate`: `Function` or `Float` between 0 and 1.
        - `:mutation_rate`: `Function` or `Float` between 0 and 1.
        - `:radiation`: `Function` or `Float` between 0 and 1.
        - `:population_size`: `Integer`.
        - `:minimize?`: `true` or `false`.
        - `:hall_of_fame`: Reference to ETS Table.
      """
      @spec run(Keyword.t()) :: Population.t()
      def run(opts \\ []) do
        evolution = Keyword.get(opts, :evolution, Genex.Evolution.Simple)

        with {:ok, population} <- seed(opts),
             {:ok, population} <- evolution.init(population, opts),
             {:ok, population} <- evolution.evaluation(population, &fitness_function/1, opts),
             {:ok, population} <-
               evolution.evolve(population, &terminate?/1, &fitness_function/1, opts) do
          evolution.termination(population, opts)
        else
          err -> raise err
        end
      end

      @doc """
      Profile your genetic algorithm.

      This function will profile your genetic algorithm.

      Returns `:ok`.
      """
      @spec profile :: :ok
      def profile(opts \\ []), do: :ok

      defp valid_opts?(opts \\ []), do: :ok

      defoverridable seed: 1, profile: 1
    end
  end

  defguard valid_rate?(rate) when is_float(rate) and rate >= 0.0 and rate <= 1.0
end
