defmodule Genex do
  alias Genex.Chromosome
  alias Genex.Operators.Crossover
  alias Genex.Operators.Mutation
  alias Genex.Operators.Selection
  alias Genex.Population
  alias Genex.Support.Genealogy
  alias Genex.Support.Statistics
  alias Genex.Visualizers.Text

  @moduledoc """
  Genetic Algorithms in Elixir!

  Genex is a simple library for creating Genetic Algorithms in Elixir. A Genetic Algorithm is a search-based optimization technique based on the principles of Genetics and Natural Selection.

  The basic life-cycle of a Genetic Algorithm is as follows:

  1) Initialize the Population
  2) Loop until goal is reached
    a) Select Parents
    b) Perform Crossover
    c) Mutate some of population
    d) Select Survivors

  Genex uses a structure similar to the one above, using callbacks to give you full control over your genetic algorithm.

  ## Implementation

  Genex requires an implementation module:

  ```
  defmodule OneMax do
    use Genex

    def encoding do
      for _ <- 1..15, do: Enum.random(0..1)
    end

    def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

    def terminate?(population), do: population.max_fitness == 15
  end
  ```

  Genex requires 3 function definitions: `encoding/0`, `fitness_function/1`, and `terminate?/1`. Let's take a closer look at each of these:

  ### Encoding
  ```
  def encoding do
    for _ <- 1..15, do: Enum.random(0..1)
  end
  ```

  `encoding/0` defines your encoding of the chromosome's genes for your use-case. In the example above, we define a Binary Gene Set of length 15. Genex uses this function to generate an initial population of Chromosomes matching your encoding.

  ### Fitness Function
  ```
  def fitness_function(chromosome) do
    Enum.sum(chromosome.genes)
  end
  ```

  `fitness_function/1` defines how the algorithm evaluates the fitness of a chromosome. It takes in a chromosome struct and returns a number. Fitness is how your algorithm determines which chromosomes should be persisted to the next generation as well as which chromosomes should be selected to crossover. In this case, we want to maximize 1's in our set of genes, so we define fitness as the sum of genes.

  ### Termination Criteria
  ```
  def terminate?(population) do
    population.max_fitness == 15
  end
  ```

  `terminate?/1` defines the termination criteria for your algorithm. This tells Genex when your algorithm should stop running. In this case we use a Max Fitness; however, you can also tell the algorithm to stop after a certain number of generations.

  ## Running

  Once you have defined an implementation module. Utilize the `run/0` function to run the algorithm. The function will return the solution population for analysis. You can display a summary of the solution with the: `Genex.Visualizers.Text.display_summary/1` function.

  ```
  soln = OneMax.run()
  Genex.Visualizers.Text.display_summary(soln)
  ```

  ## Configuration

  Genex offers a number of settings to adjust the algorithm to your liking. You can adjust: strategies, rates, and more. See the [configuration](https://hexdocs.pm/genex/introduction-configuration.html) guide for a full list.

  ## Customization

  You can customize every step of your genetic algorithm utilizing one or more of the many callbacks Genex provides. See the [customization](https://hexdocs.pm/genex/introduction-customization.html) guide for more.
  """

  @doc """
  Generates a random gene set.
  """
  @callback encoding :: Enum.t()

  @doc """
  Seeds a population.
  """
  @callback seed :: {:ok, Population.t()}

  @doc """
  Evaluates a population's fitness.
  """
  @callback evaluate(population :: Population.t()) :: number()

  @doc """
  Specifies the statistics to collect on the population.
  """
  @callback statistics :: Keyword.t()

  @doc """
  Calculates a Chromosome's fitness.
  """
  @callback fitness_function(chromosome :: Chromosome.t()) :: number()

  @doc """
  Crossover rate as a function of the population.
  """
  @callback crossover_rate(Population.t()) :: number()

  @doc """
  Mutation rate as a function of the population.
  """
  @callback mutation_rate(Population.t()) :: number()

  @doc """
  Radiation level (aggressiveness) of mutation as a function of the population.
  """
  @callback radiation(Population.t()) :: number()

  @doc """
  Selects a number of individuals for crossover, depending on the `crossover_rate`.
  """
  @callback select_parents(population :: Population.t()) ::
              {:ok, Population.t()} | {:error, any()}

  @doc """
  Crossover a number of individuals to create a new population.
  """
  @callback crossover(population :: Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Mutate a number of individuals, depending on the `mutation_rate`.
  """
  @callback mutate(population :: Population.t()) :: {:ok, Population.t()} | {:error, any()}

  @doc """
  Select a number of individuals to survive to the next generation, depending on the `crossover_rate`.s
  """
  @callback select_survivors(population :: Population.t()) ::
              {:ok, Population.t()} | {:error, any()}

  @doc """
  Tests the population for some termination criteria.
  """
  @callback terminate?(population :: Population.t()) :: boolean()

  defmacro __using__(opts \\ []) do
    # Population
    population_size = Keyword.get(opts, :population_size, 100)

    # Strategies
    parent_selection_type = Keyword.get(opts, :parent_selection, :natural)
    survivor_selection_type = Keyword.get(opts, :survivor_selection, :natural)
    crossover_type = Keyword.get(opts, :crossover_type, :single_point)
    mutation_type = Keyword.get(opts, :mutation_type, :scramble)

    # Unique to some algorithms
    uniform_crossover_rate = Keyword.get(opts, :uniform_crossover_rate, nil)
    alpha = Keyword.get(opts, :alpha, nil)
    eta = Keyword.get(opts, :eta, nil)
    lower_bound = Keyword.get(opts, :lower_bound, nil)
    upper_bound = Keyword.get(opts, :upper_bound, nil)
    tournsize = Keyword.get(opts, :tournsize, nil)

    # Other
    minimize = Keyword.get(opts, :minimize, false)

    quote do
      @behaviour Genex

      alias Genex.Chromosome
      alias Genex.Population
      alias Genex.Support.Statistics

      # Population Characteristics
      @population_size unquote(population_size)

      # Strategies
      @crossover_type unquote(crossover_type)
      @mutation_type unquote(mutation_type)
      @survivor_selection_type unquote(survivor_selection_type)
      @parent_selection_type unquote(parent_selection_type)

      # Unique Algorithm Parameters
      @uniform_crossover_rate unquote(uniform_crossover_rate)
      @alpha unquote(alpha)
      @eta unquote(eta)
      @min unquote(lower_bound)
      @max unquote(upper_bound)
      @tournsize unquote(tournsize)

      # Other
      @minimize unquote(minimize)

      @doc """
      Define the crossover rate as a function of `Population`.

      This allows for a changing crossover rate based on population parameters.

      Returns `Number`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec crossover_rate(Population.t()) :: number()
      def crossover_rate(_), do: 0.75

      @doc """
      Define the crossover rate as a function of `Population`.

      This allows for a changing mutation rate based on population parameters.

      Returns `Number`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec mutation_rate(Population.t()) :: number()
      def mutation_rate(_), do: 0.05

      @doc """
      Define the radiation level as a function of `Population`.

      This changes the "aggressiveness" of mutations based on population parameters.

      Returns `Number`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec radiation(Population.t()) :: number()
      def radiation(_), do: 0.5

      @doc """
      Seed the population with some chromosomes.

      This function is the first step in the Genetic Algorithm. By default, it makes calls to the encoding function defined by the user to create `n` chromosomes where `n` is the specified `population_size`. By default, `population_size` is set to 100.

      Returns `{:ok, Population}`.
      """
      @spec seed :: {:ok, Chromosome.t()}
      def seed do
        history = Genealogy.init()

        chromosomes =
          for n <- 1..@population_size do
            g = encoding()
            c = %Chromosome{genes: g, size: length(g)}
            c
          end

        history =
          history
          |> Genealogy.add_generation(chromosomes)

        pop = %Population{chromosomes: chromosomes, size: @population_size, history: history}
        {:ok, pop}
      end

      @doc """
      Evalutes the population using the fitness function.

      This function takes the population and evaluates each chromosome for it's fitness. It attaches this fitness value to the chromosome for use in later parts of the algorithm. This function also sets the strongest chromosome as well as the max_fitness for the current iteration for use in the termination function.

      Returns `{:ok, Population}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec evaluate(Population.t()) :: {:ok, Population.t()}
      def evaluate(population) do
        chromosomes =
          population.chromosomes
          |> Enum.map(fn c -> %Chromosome{c | fitness: fitness_function(c)} end)

        pop = Population.sort(%Population{population | chromosomes: chromosomes}, @minimize)
        {:ok, pop}
      end

      @doc """
      Specifies the statistics to track throughout the algorithm.

      This function should return a Keyword list formatted like:
        `[stat: &function/1]`
      All functions should take a list.

      Returns `Keyword.t`.
      """
      @spec statistics :: Keyword.t()
      def statistics do
        [
          mean: &Statistics.mean/1,
          variance: &Statistics.variance/1,
          stdev: &Statistics.stdev/1,
          max: &Statistics.max/1,
          min: &Statistics.min/1
        ]
      end

      @doc """
      Life cycle of the genetic algorithm.

      This function represents the life cycle loop of the genetic algorithm. By default the steps are:
        - Parent Selection
        - Crossover
        - Mutation
        - Survivor Selection
        - Generation Advancement
        - Population Evaluation
      The function executes until terminate? tells it to stop.

      Returns `{:ok, Population}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec cycle(Population.t()) :: {:ok, Population.t()}
      def cycle(population) do
        if terminate?(population) do
          {:ok, population}
        else
          Text.display_summary(population)

          with {:ok, population} <- select_parents(population),
               {:ok, population} <- crossover(population),
               {:ok, population} <- mutate(population),
               {:ok, population} <- select_survivors(population),
               {:ok, population} <- advance(population),
               {:ok, population} <- evaluate(population),
               {:ok, population} <- do_statistics(population) do
            cycle(population)
          else
            {:error, reason} -> raise reason
          end
        end
      end

      @doc """
      Selects a number of parents from `population` to crossover.

      This function by default matches the "parent_selection" setting to the corresponding Selection function. It returns an error if no match is found. If you want to customize this function, you can do so by overriding it. You must ensure the function you write populates the `parents` field of the Population struct in order for the rest of the algorithm to run properly.

      Returns `{:ok, Population}` or `{:error, "Invalid Selection Type."}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec select_parents(Population.t()) :: {:ok, Population.t()} | {:error, String.t()}
      def select_parents(population) do
        case @parent_selection_type do
          :natural ->
            do_parent_selection(population, crossover_rate(population), &Selection.natural/2, [])

          :worst ->
            do_parent_selection(population, crossover_rate(population), &Selection.worst/2, [])

          :random ->
            do_parent_selection(population, crossover_rate(population), &Selection.random/2, [])

          :roulette ->
            do_parent_selection(population, crossover_rate(population), &Selection.roulette/2, [])

          :tournament ->
            do_parent_selection(population, crossover_rate(population), &Selection.tournament/3, [
              @tournsize
            ])

          :stochastic ->
            do_parent_selection(
              population,
              crossover_rate(population),
              &Selection.stochastic_universal_sampling/2,
              []
            )

          _ ->
            {:error, "Invalid Selection Type"}
        end
      end

      @doc """
      Creates new individuals from parents.

      This function by default matches the "crossover_type" setting to the corresponding Crossover function. It returns an error if no match is found. If you want to customize this function, you can do so by overriding it. You must ensure the function you write populates the `children` field of the Population struct in order for the rest of the algorithm to run properly.

      Returns `{:ok, Population}` or `{:error, "Invalid Crossover Type."}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec crossover(Population.t()) :: {:ok, Population.t()} | {:error, String.t()}
      def crossover(population) do
        case @crossover_type do
          :single_point -> do_crossover(population, &Crossover.single_point/2, [])
          :two_point -> do_crossover(population, &Crossover.two_point/2, [])
          :uniform -> do_crossover(population, &Crossover.uniform/3, [@uniform_crossover_rate])
          :blend -> do_crossover(population, &Crossover.blend/3, [@alpha])
          :simulated_binary -> do_crossover(population, &Crossover.simulated_binary/3, [@eta])
          :messy_single_point -> do_crossover(population, &Crossover.messy_single_point/2, [])
          :davis_order -> do_crossover(population, &Crossover.davis_order/2, [])
          _ -> {:error, "Invalid Crossover Type."}
        end
      end

      @doc """
      Mutates a number of chromosomes.

      This function by default matches the "mutation_type" setting to the corresponding Mutation function. It returns an error if no match is found. If you want to customize this function, you can do so by overriding it. The default function works by mutating the `chromosomes` field of the Population struct.

      Returns `{:ok, Population}` or `{:error, "Invalid Mutation Type".}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec mutate(Population.t()) :: {:ok, Population.t()} | {:error, String.t()}
      def mutate(population) do
        case @mutation_type do
          :bit_flip ->
            do_mutation(population, &Mutation.bit_flip/2, [radiation(population)])

          :scramble ->
            do_mutation(population, &Mutation.scramble/2, [radiation(population)])

          :invert ->
            do_mutation(population, &Mutation.invert/2, [radiation(population)])

          :uniform_integer ->
            do_mutation(population, &Mutation.uniform_integer/4, [
              radiation(population),
              @min,
              @max
            ])

          :gaussian ->
            do_mutation(population, &Mutation.gaussian/2, [radiation(population)])

          :polynomial_bounded ->
            do_mutation(population, &Mutation.polynomial_bounded/5, [
              radiation(population),
              @eta,
              @min,
              @max
            ])

          :none ->
            {:ok, population}

          _ ->
            {:error, "Invalid Mutation Type."}
        end
      end

      @doc """
      Selects a number of individuals to survive to the next generation.

      This function by default matches the "survivor_selection" setting to the corresponding Selection function. It returns an error if no match is found. If you want to customize this function, you can do so by overriding it. You must ensure the function you write populates the `survivors` field of the Population struct in order for the rest of the algorithm to run properly.

      Returns `{:ok, Population}` or `{:error, "Invalid Selection Type."}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec select_survivors(Population.t()) :: {:ok, Population.t()} | {:error, String.t()}
      def select_survivors(population) do
        case @survivor_selection_type do
          :natural ->
            do_survivor_selection(population, &Selection.natural/2, [])

          :worst ->
            do_survivor_selection(population, &Selection.worst/2, [])

          :random ->
            do_survivor_selection(population, &Selection.random/2, [])

          :roulette ->
            do_survivor_selection(population, &Selection.roulette/2, [])

          :tournament ->
            do_survivor_selection(population, &Selection.tournament/3, [@tournsize])

          :stochastic ->
            do_survivor_selection(population, &Selection.stochastic_universal_sampling/2, [])

          _ ->
            {:error, "Invalid Selection Type"}
        end
      end

      @doc """
      Advance to the next generation.

      This function's purpose is to increment the generation, kill off chromosomes, and create the new population while persisting the relevant information to the next generation. This is mainly a bookkeeping step.

      Returns `{:ok, Population}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec advance(Population.t()) :: {:ok, Population.t()}
      def advance(population) do
        generation = population.generation + 1

        survivors =
          population.survivors
          |> Enum.map(fn c -> %Chromosome{c | age: c.age + 1} end)

        chromosomes = survivors ++ population.children
        size = length(chromosomes)

        pop = %Population{
          population
          | size: size,
            chromosomes: chromosomes,
            generation: generation,
            children: nil,
            parents: nil,
            survivors: nil
        }

        {:ok, pop}
      end

      @doc """
      Run the genetic algorithm.

      This function combines all previous steps and executes the Genetic Algorithm until completion. It will return the solution population which contains relevant information for analysis of your algorithms performance.

      Returns `%Population{...}`.
      """
      @spec run :: Population.t()
      def run do
        Text.init()

        with {:ok, population} <- seed(),
             {:ok, population} <- evaluate(population),
             {:ok, population} <- cycle(population) do
          soln = Population.sort(population, @minimize)
          soln
        else
          {:error, reason} -> raise reason
        end
      end

      @doc """
      Benchmark your genetic algorithm.

      This function will benchmark every function defined in your Genetic Algorithm.

      Returns `:ok`.
      """
      @spec benchmark :: :ok
      def benchmark do
        IO.write("Benchmarking your algorith. This may take awhile...\n")
        {:ok, init_pop} = seed()
        {:ok, evaluated_pop} = evaluate(init_pop)
        {:ok, parent_pop} = select_parents(evaluated_pop)
        {:ok, child_pop} = crossover(parent_pop)
        {:ok, mutated_pop} = mutate(child_pop)
        {:ok, survivor_pop} = select_survivors(mutated_pop)
        genes = encoding()
        c = %Chromosome{genes: genes, size: length(genes)}

        Benchee.run(%{
          "encoding/0" => fn -> encoding() end,
          "seed/0" => fn -> seed() end,
          "fitness_function/1" => fn -> fitness_function(c) end,
          "terminate?/1" => fn -> terminate?(survivor_pop) end,
          "evaluate/1" => fn -> evaluate(init_pop) end,
          "select_parents/1" => fn -> select_parents(evaluated_pop) end,
          "crossover/1" => fn -> crossover(parent_pop) end,
          "mutate/1" => fn -> mutate(child_pop) end,
          "select_survivors/1" => fn -> select_survivors(mutated_pop) end
        })

        :ok
      end

      defp do_crossover(population, f, args) do
        parents = population.parents

        {children, history} =
          parents
          |> Enum.reduce(
            {[], population.history},
            fn {p1, p2}, {chd, his} ->
              {c1, c2} = apply(f, [p1, p2] ++ args)

              newHis =
                his
                |> Genealogy.update(c1, p1, p2)
                |> Genealogy.update(c1, p1, p2)

              {[c1 | [c2 | chd]], newHis}
            end
          )

        pop = %Population{population | children: children, history: history}
        {:ok, pop}
      end

      defp do_mutation(population, f, args) do
        u = mutation_rate(population)

        chromosomes =
          population.chromosomes
          |> Enum.map(fn c ->
            if :rand.uniform() < u do
              apply(f, [c] ++ args)
            else
              c
            end
          end)

        pop = %Population{population | chromosomes: chromosomes}
        {:ok, pop}
      end

      defp do_parent_selection(population, rate, f, args)
           when is_float(rate) and rate >= 0.0 and rate <= 1.0 do
        chromosomes = population.chromosomes
        n = floor(rate * length(chromosomes))

        parents =
          f
          |> apply([chromosomes, n] ++ args)
          |> Enum.chunk_every(2, 2, :discard)
          |> Enum.map(fn f -> List.to_tuple(f) end)

        pop = %Population{population | parents: parents}
        {:ok, pop}
      end

      defp do_parent_selection(_, _, _, _), do: raise("Invalid crossover rate!")

      defp do_survivor_selection(population, f, args) do
        chromosomes = population.chromosomes
        n = population.size - length(population.children)
        survivors = apply(f, [chromosomes, n] ++ args)
        pop = %Population{population | survivors: survivors}
        {:ok, pop}
      end

      defp do_statistics(population) do
        stats =
          statistics()
          |> Enum.map(fn {k, v} ->
            val =
              population.chromosomes
              |> Enum.map(fn c -> c.fitness end)
              |> v.()

            {:"#{k}", val}
          end)

        pop = %Population{population | statistics: stats}
        {:ok, pop}
      end

      defoverridable select_parents: 1,
                     crossover: 1,
                     mutate: 1,
                     select_survivors: 1,
                     seed: 0,
                     evaluate: 1,
                     advance: 1,
                     cycle: 1,
                     statistics: 0,
                     benchmark: 0,
                     crossover_rate: 1,
                     mutation_rate: 1,
                     radiation: 1
    end
  end

  defguard valid_rate?(rate) when is_float(rate) and rate >= 0.0 and rate <= 1.0
end
