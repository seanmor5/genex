defmodule Genex do
  alias Genex.Support.Genealogy
  alias Genex.Types.Chromosome
  alias Genex.Types.Population
  alias Genex.Visualizers.Text

  @doc """
  Generates a random gene set.
  """
  @callback encoding :: Enum.t()

  @doc """
  Seeds a population.
  """
  @callback seed(opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Evaluates a chromosome
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

      def match_evolution(opts) do
        evolution_type = Keyword.get(opts, :evolution_type, :simple)

        case evolution_type do
          :simple -> Genex.Evolution.Simple
          _ -> raise "Invalid Evolutin Type!"
        end
      end

      @doc """
      Seed the population with some chromosomes.

      Returns `Enum.t(%Chromosomes{})`.

      # Parameters

        - `opts`: Keyword list of options.
      """
      @spec seed(Keyword.t()) :: Enum.t(Chromosome.t())
      def seed(opts \\ []) do
        size = Keyword.get(opts, :population_size, 100)

        chromosomes =
          for n <- 1..size do
            g = encoding()
            c = %Chromosome{genes: g, size: length(g)}
            c
          end

        chromosomes
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
        Text.init()

        evolve = &match_evolution(opts).evolve/4

        with {:ok, population} <- init_and_evaluate(opts),
             {:ok, population} <- evolve.(population, &terminate?/1, &fitness_function/1, opts) do
          soln = Population.sort(population, true)
        else
          err -> raise err
        end
      end

      @doc """
      Benchmark your genetic algorithm.

      This function will benchmark every function defined in your Genetic Algorithm.

      Returns `:ok`.
      """
      @spec benchmark :: :ok
      def benchmark(opts \\ []), do: :ok

      defp init_and_evaluate(opts) do
        # Initialize necessary fields
        chromosomes = seed(opts)
        history = Genealogy.init() |> Genealogy.add_generation(chromosomes)

        # Initialize the population
        pop = %Population{chromosomes: chromosomes, history: history, size: length(chromosomes)}

        # Find and apply the eval strategy
        eval = &match_evolution(opts).evaluation/3
        eval.(pop, &fitness_function/1, opts)
      end

      defoverridable seed: 1
    end
  end

  defguard valid_rate?(rate) when is_float(rate) and rate >= 0.0 and rate <= 1.0
end
