defmodule Genex do
  alias Genex.Chromosome
  alias Genex.Operators.Crossover
  alias Genex.Operators.Mutation
  alias Genex.Operators.Selection
  alias Genex.Population
  alias Genex.Visualizers.Text

  @moduledoc """
  Genex Makes writing genetic algorithms EASY.
  """

  @doc """
  Generates a random gene set.
  """
  @callback individual :: Enum.t()

  @doc """
  Generates a population.
  """
  @callback seed :: {:ok, Population.t()}

  @doc """
  Evaluates a population's fitness.
  """
  @callback evaluate(Population.t()) :: number()

  @doc """
  Calculates a Chromosome's fitness.
  """
  @callback fitness_function(Chromosome.t()) :: number()

  @doc """
  Selects a number of individuals for crossover.
  The number of individuals selected depends on the crossover rate. This phase populates the `parent` field of the population struct with a `List` of tuples. Each tuple is a pair of parents to crossover.
  """
  @callback select_parents(Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Crossover a number of individuals to create a new population.
  The number of individuals depends on the crossover rate. This phase populates the `children` field of the populaton struct with a `List` of `Chromosomes`.
  """
  @callback crossover(Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Mutate a number of individuals to add novelty to the population.
  The number of individuals depends on the mutation rate. This phase populates the `mutant` field of the population struct with a `List` of `Chromosomes`.
  """
  @callback mutate(Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Select a number of individuals to survive to the next generation.
  The number of individuals depends on the survival rate. This phase populates the `survivors` field of the population struct with a `List` of `Chromosomes`.
  """
  @callback select_survivors(Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Tests the population for some termination criteria.
  """
  @callback terminate?(Population.t) :: boolean()

  defmacro __using__(opts \\ []) do
    # Population
    population_size = Keyword.get(opts, :population_size, 100)

    # Strategies
    parent_selection_type = Keyword.get(opts, :parent_selection, :natural)
    survivor_selection_type = Keyword.get(opts, :survivor_selection, :natural)
    crossover_type = Keyword.get(opts, :crossover_type, :single_point)
    mutation_type = Keyword.get(opts, :mutation_type, :shuffle_index)

    # Rates
    survival_rate = Keyword.get(opts, :survival_rate, 0.25)
    crossover_rate = Keyword.get(opts, :crossover_rate, 0.75)
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)

    # Unique to some algorithms
    uniform_crossover_rate = Keyword.get(opts, :uniform_crossover_rate, nil)

    quote do
      @behaviour Genex

      alias Genex.Chromosome
      alias Genex.Population

      # Population Characteristics
      @population_size unquote(population_size)

      # Strategies
      @crossover_type unquote(crossover_type)
      @mutation_type unquote(mutation_type)
      @survivor_selection_type unquote(survivor_selection_type)
      @parent_selection_type unquote(parent_selection_type)

      # Rates
      @crossover_rate unquote(crossover_rate)
      @mutation_rate unquote(mutation_rate)
      @survival_rate unquote(survival_rate)

      # Unique Algorithm Parameters
      @uniform_crossover_rate unquote(uniform_crossover_rate)

      @doc """
      Seed the population with some chromosomes.
      """
      def seed do
        Text.initialize()
        chromosomes =
          for n <- 1..@population_size do
            %Chromosome{genes: individual()}
          end
        pop = %Population{chromosomes: chromosomes, size: @population_size}
        {:ok, pop}
      end

      @doc """
      Evalutes the population using the fitness function.
      """
      def evaluate(population) do
        chromosomes =
          population.chromosomes
          |> Enum.map(fn c -> %Chromosome{genes: c.genes, fitness: fitness_function(c)} end)
        max_fitness = Enum.max_by(chromosomes, &Chromosome.get_fitness/1).fitness
        pop = %Population{population | chromosomes: chromosomes, max_fitness: max_fitness}
        {:ok, pop}
      end

      @doc """
      Life cycle of the genetic algorithm.
      """
      def cycle(population) do
        if terminate?(population) do
          {:ok, population}
        else
          Text.summary(population)
          with {:ok, population} <- select_parents(population),
               {:ok, population} <- crossover(population),
               {:ok, population} <- mutate(population),
               {:ok, population} <- select_survivors(population),
               {:ok, population} <- advance(population),
               {:ok, population} <- evaluate(population) do
                 cycle(population)
          else
            {:error, reason} -> raise reason
          end
        end
      end

      @doc """
      Selects a number of parents from `population` to crossover.
      """
      def select_parents(population) do
        case @parent_selection_type do
          :natural    -> Selection.natural(population, :parents, @crossover_rate)
          :worst      -> Selection.worst(population, :parents, @crossover_rate)
          :random     -> Selection.random(population, :parents, @crossover_rate)
          :roulette   -> Selection.roulette(population, :parents, @crossover_rate)
          :tournament -> Selection.tournament(population, :parents, @crossover_rate)
          :stochastic -> Selection.stochastic(population, :parents, @crossover_rate)
          _           -> {:error, "Invalid Selection Type"}
        end
      end

      @doc """
      Creates new individuals from parents.
      """
      def crossover(population) do
        case @crossover_type do
          :single_point     -> Crossover.single_point(population)
          :multi_point      -> Crossover.multi_point(population)
          :uniform          -> Crossover.uniform(population, @uniform_crossover_rate)
          :davis_order      -> Crossover.davis_order(population)
          :whole_arithmetic -> Crossover.whole_arithmetic
          _                 -> {:error, "Invalid Crossover Type"}
        end
      end

      @doc """
      Mutates a number of chromosomes.
      """
      def mutate(population) do
        case @mutation_type do
          :bit_flip        -> Mutation.bit_flip(population, @mutation_rate)
          :uniform_integer -> Mutation.uniform_integer(population, @mutation_rate)
          :gaussian        -> Mutation.gaussian(population, @mutation_rate)
          :scramble        -> Mutation.scramble(population, @mutation_rate)
          :shuffle_index   -> Mutation.shuffle_index(population, @mutation_rate)
          :invert          -> Mutation.invert(population, @mutation_rate)
          :none            -> {:ok, population}
          _                -> {:error, "Invalid Mutation Type"}
        end
      end

      @doc """
      Selects a number of individuals to survive to the next generation.
      """
      def select_survivors(population) do
        case @survivor_selection_type do
          :natural    -> Selection.natural(population, :survivors, @survival_rate)
          :worst      -> Selection.worst(population, :survivors, @survival_rate)
          :random     -> Selection.random(population, :survivors, @survival_rate)
          :roulette   -> Selection.roulette(population, :survivors, @survival_rate)
          :tournament -> Selection.tournament(population, :survivors, @survival_rate)
          :stochastic -> Selection.stochastic(population, :survivors, @survival_rate)
          _           -> {:error, "Invalid Selection Type"}
        end
      end

      @doc """
      Advance to the next generation.
      """
      def advance(population) do
        generation = population.generation+1
        chromosomes = population.survivors ++ population.children
        pop = %Population{population | chromosomes: chromosomes, generation: generation}
        {:ok, pop}
      end

      @doc """
      Run the genetic algorithm.
      """
      def run do
        with {:ok, population} <- seed(),
             {:ok, population} <- evaluate(population),
             {:ok, population} <- cycle(population) do
               Text.solution(Population.sort(population))
        else
          {:error, reason} -> raise reason
        end
      end

      defoverridable [
        select_parents: 1,
        crossover: 1,
        mutate: 1,
        select_survivors: 1,
        seed: 0
      ]
    end
  end

end
