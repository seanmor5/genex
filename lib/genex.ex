defmodule Genex do
  alias Genex.Population
  alias Genex.Chromosome
  use Genex.Tools

  @doc """
  Generates a random gene set. 
  """
  @callback chromosome :: Enum.t()

  @doc """
  Calculates the fitness of a `Chromosome`.
  """
  @callback fitness_function(Enum.t()) :: number()

  @doc """
  Selects a number of individuals for crossover.
  The number of individuals selected depends on the crossover rate. This phase populates the `parent` field of the population struct with a `List` of tuples. Each tuple is a pair of parents to crossover.
  """
  @callback parent_selection(Population.t()) :: {:ok, Population.t()} | {:error, any()}

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
  @callback survivor_selection(Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Tests the population for some termination criteria.
  """
  @callback goal_test(Population.t) :: boolean()

  defmacro __using__(opts \\ []) do
    # Population
    population_size = Keyword.get(opts, :population_size, 100)

    # Strategies
    parent_selection_type = Keyword.get(opts, :parent_selection, :natural)
    survivor_selection_type = Keyword.get(opts, :survivor_selection, :natural)
    crossover_type = Keyword.get(opts, :crossover_type, :single_point)
    mutation_type = Keyword.get(opts, :mutation_type, :bit_flip)

    # Rates
    survival_rate = Keyword.get(opts, :survival_rate, 0.25)
    crossover_rate = Keyword.get(opts, :crossover_rate, 0.75)
    mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)

    # Unique to some algorithms
    uniform_crossover_rate = Keyword.get(opts, :uniform_crossover_rate, nil)
    multi_num_points = Keyword.get(opts, :multi_num_points, nil)

    quote do
      alias Genex.Chromosome
      alias Genex.Population
      @behaviour Genex

      @crossover_rate unquote(crossover_rate)
      @crossover_type unquote(crossover_type)
      @mutation_rate unquote(mutation_rate)
      @survival_rate unquote(survival_rate)
      @mutation_type unquote(mutation_type)
      @survivor_selection_type unquote(survivor_selection_type)
      @parent_selection_type unquote(parent_selection_type)
      @population_size unquote(population_size)
      @uniform_crossover_rate unquote(uniform_crossover_rate)
      @multi_num_points unquote(multi_num_points)

      @doc """
      Selects a number of parents from `population` to crossover.
      """
      def parent_selection(population) do
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
          :multi_point      -> Crossover.multi_point(population, @multi_num_points)
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
          _                -> {:error, "Invalid Mutation Type"}
        end
      end

      @doc """
      Selects a number of individuals to survive to the next generation.
      """
      def survivor_selection(population) do
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
      Run the genetic algorithm.
      """
      def run do
        with {:ok, population} <- init(),
             {:ok, population} <- calculate_fitness(population),
             {:ok, population} <- gen_loop(population) do
               print_solution(population)
             end
      end

      defp init do
        chromosomes = 
          for n <- 1..@population_size do
            %Chromosome{genes: chromosome()}
          end
        pop = %Population{chromosomes: chromosomes}
        {:ok, pop}
      end

      defp calculate_fitness(population) do 
        chromosomes = population.chromosomes
        with_fitness = 
          chromosomes
          |> Enum.map(fn c -> %Chromosome{genes: c.genes, fitness: fitness_function(c.genes)} end)
        max_fitness = Enum.max_by(with_fitness, &Chromosome.get_fitness/1).fitness
        new_pop = %Population{population | chromosomes: with_fitness}
        newer_pop = %Population{new_pop | max_fitness: max_fitness}
        {:ok, newer_pop}
      end

      defp next_generation(population) do
        next_gen = population.generation+1
        survivors = population.survivors
        children = population.children
        new_chromosomes = survivors ++ children
        new_population = %Population{chromosomes: new_chromosomes, generation: next_gen}
        {:ok, new_population}
      end

      defp gen_loop(population) do
        if not goal_test(population) do
          IO.write("\rMax Fitness: #{population.max_fitness}")
          with {:ok, population} <- parent_selection(population),
               {:ok, population} <- crossover(population),
               {:ok, population} <- mutate(population),
               {:ok, population} <- survivor_selection(population),
               {:ok, population} <- next_generation(population),
               {:ok, population} <- calculate_fitness(population) do
                 gen_loop(population)
               end
        else
          print_solution(population)
        end
      end

      defp print_solution(population) do
        soln = hd(Population.sort(population).chromosomes).genes
        IO.write("\r###############################################\n")
        IO.puts("Solution: ")
        IO.inspect(soln)
        IO.puts("\nMax Fitness: #{population.max_fitness}\n")
        IO.puts("Generation: #{population.generation}")
        IO.write("###############################################\n")
      end

      defoverridable [
        parent_selection: 1,
        crossover: 1,
        mutate: 1,
        survivor_selection: 1
      ]
    end 
  end

end
