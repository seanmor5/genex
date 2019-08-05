defmodule Genex do
  alias Genex.Chromosome
  alias Genex.Operators.Crossover
  alias Genex.Operators.Mutation
  alias Genex.Operators.Selection
  alias Genex.Population
  alias Genex.Support.Genealogy
  alias Genex.Visualizers.Text

  @moduledoc """
  Genetic Algorithms in Elixir.
  """

  @doc """
  Generates a random gene set.
  """
  @callback individual :: Enum.t()

  @doc """
  Seeds a population.
  """
  @callback seed :: {:ok, Population.t()}

  @doc """
  Evaluates a population's fitness.
  """
  @callback evaluate(population :: Population.t()) :: number()

  @doc """
  Calculates a Chromosome's fitness.
  """
  @callback fitness_function(chromosome :: Chromosome.t()) :: number()

  @doc """
  Selects a number of individuals for crossover.
  The number of individuals selected depends on the crossover rate. This phase populates the `parent` field of the population struct with a `List` of tuples. Each tuple is a pair of parents to crossover.
  """
  @callback select_parents(population :: Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Crossover a number of individuals to create a new population.
  The number of individuals depends on the crossover rate. This phase populates the `children` field of the populaton struct with a `List` of `Chromosomes`.
  """
  @callback crossover(population :: Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Mutate a number of individuals to add novelty to the population.
  The number of individuals depends on the mutation rate. This phase populates the `mutant` field of the population struct with a `List` of `Chromosomes`.
  """
  @callback mutate(population :: Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Select a number of individuals to survive to the next generation.
  The number of individuals depends on the survival rate. This phase populates the `survivors` field of the population struct with a `List` of `Chromosomes`.
  """
  @callback select_survivors(population :: Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Tests the population for some termination criteria.
  """
  @callback terminate?(population :: Population.t) :: boolean()

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
    alpha = Keyword.get(opts, :alpha, nil)

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
      @alpha unquote(alpha)

      @doc """
      Seed the population with some chromosomes.
      """
      def seed do
        Text.init()
        history = Genealogy.init()
        chromosomes =
          for n <- 1..@population_size do
            c = %Chromosome{genes: individual()}
            Genealogy.update(history, c)
            c
          end
        pop = %Population{chromosomes: chromosomes, size: @population_size, history: history}
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
          :natural    -> Selection.natural(population, @crossover_rate)
          :worst      -> Selection.worst(population, @crossover_rate)
          :random     -> Selection.random(population, @crossover_rate)
          :roulette   -> Selection.roulette(population, @crossover_rate)
          :tournament -> Selection.tournament(population, @crossover_rate)
          :stochastic -> Selection.stochastic(population, @crossover_rate)
          _           -> {:error, "Invalid Selection Type"}
        end
      end

      @doc """
      Creates new individuals from parents.
      """
      def crossover(population) do
        case @crossover_type do
          :single_point     -> do_crossover(population, &Crossover.single_point/2)
          :two_point        -> do_crossover(population, &Crossover.two_point/2)
          :uniform          -> do_crossover(population, &Crossover.uniform/3, [@uniform_crossover_rate])
          :blend            -> do_crossover(population, &Crossover.blend/3, [@alpha])
          _                 -> {:error, "Invalid Crossover Type"}
        end
      end

      @doc """
      Mutates a number of chromosomes.
      """
      def mutate(population) do
        case @mutation_type do
          :bit_flip        -> do_mutation(population, &Mutation.bit_flip/1)
          :scramble        -> do_mutation(population, &Mutation.scramble/1)
          :invert          -> do_mutation(population, &Mutation.invert/1)
          :none            -> {:ok, population}
          _                -> {:error, "Invalid Mutation Type"}
        end
      end

      @doc """
      Selects a number of individuals to survive to the next generation.
      """
      def select_survivors(population) do
        case @survivor_selection_type do
          :natural    -> Selection.natural(population)
          :worst      -> Selection.worst(population)
          :random     -> Selection.random(population)
          :roulette   -> Selection.roulette(population)
          :tournament -> Selection.tournament(population)
          :stochastic -> Selection.stochastic(population)
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
               soln = Population.sort(population)
               Text.solution(soln)
               soln
        else
          {:error, reason} -> raise reason
        end
      end

      defp do_crossover(population, f) do
        parents = population.parents
        children =
          parents
          |> Enum.map(
              fn {p1, p2} ->
                c = f.(p1, p2)
                Genealogy.update(population.history, c, p1, p2)
                c
              end
            )
        pop = %Population{population | children: children}
        {:ok, pop}
      end
      defp do_crossover(population, f, args) do
        parents = population.parents
        children =
          parents
          |> Enum.map(
            fn {p1, p2} ->
              c = apply(f, [p1, p2] ++ args)
              Genealogy.update(population.history, c, p1, p2)
              c
            end
          )
        pop = %Population{population | children: children}
        {:ok, pop}
      end

      defp do_mutation(population, f) do
        chromosomes =
          population.chromosomes
          |> Enum.map(
            fn c ->
              if :rand.uniform() < @mutation_rate do
                f.(c)
              else
                c
              end
            end
          )
       pop = %Population{population | chromosomes: chromosomes}
       {:ok, pop}
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
