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
  @callback seed(opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Evaluates a population's fitness.
  """
  @callback evaluate(population :: Population.t(), opts :: Keyword.t()) :: number()

  @doc """
  Specifies the statistics to collect on the population.
  """
  @callback statistics :: Keyword.t()

  @doc """
  Calculates a Chromosome's fitness.
  """
  @callback fitness_function(chromosome :: Chromosome.t()) :: number()

  @doc """
  Selects a number of individuals for crossover, depending on the `crossover_rate`.
  """
  @callback select_parents(population :: Population.t()) ::
              {:ok, Population.t()} | {:error, any()}

  @doc """
  Crossover a number of individuals to create a new population.
  """
  @callback crossover(population :: Population.t(), opts :: Keyword.t()) ::
              {:ok, Population.t()} | {:error, any()}

  @doc """
  Mutate a number of individuals, depending on the `mutation_rate`.
  """
  @callback mutate(population :: Population.t(), opts :: Keyword.t()) ::
              {:ok, Population.t()} | {:error, any()}

  @doc """
  Select a number of individuals to survive to the next generation, depending on the `crossover_rate`.s
  """
  @callback select_survivors(population :: Population.t(), opts :: Keyword.t()) ::
              {:ok, Population.t()} | {:error, any()}

  @doc """
  Tests the population for some termination criteria.
  """
  @callback terminate?(population :: Population.t()) :: boolean()

  defmacro __using__(opts \\ []) do
    minimize = Keyword.get(opts, :minimize, false)

    quote do
      @behaviour Genex
      alias Genex.Chromosome
      alias Genex.Population
      alias Genex.Support.Statistics
      use Genex.Config
      # Other
      @minimize unquote(minimize)

      @doc """
      Seed the population with some chromosomes.

      This function is the first step in the Genetic Algorithm. By default, it makes calls to the encoding function defined by the user to create `n` chromosomes where `n` is the specified `population_size`. By default, `population_size` is set to 100.

      Returns `{:ok, Population}`.

      # Parameters

        - `opts`: Keyword list of options.
      """
      @spec seed(Keyword.t()) :: {:ok, Chromosome.t()}
      def seed(opts \\ []) do
        size = Keyword.get(opts, :population_size, 100)
        history = Genealogy.init()

        chromosomes =
          for n <- 1..size do
            g = encoding()
            c = %Chromosome{genes: g, size: length(g)}
            c
          end

        history =
          history
          |> Genealogy.add_generation(chromosomes)

        pop = %Population{chromosomes: chromosomes, size: size, history: history}
        {:ok, pop}
      end

      @doc """
      Evalutes the population using the fitness function.

      This function takes the population and evaluates each chromosome for it's fitness. It attaches this fitness value to the chromosome for use in later parts of the algorithm. This function also sets the strongest chromosome as well as the max_fitness for the current iteration for use in the termination function.

      Returns `{:ok, Population}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec evaluate(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def evaluate(population, _opts \\ []) do
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
      @spec cycle(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def cycle(population, opts \\ []) do
        if terminate?(population) do
          {:ok, population}
        else
          Text.display_summary(population)

          with {:ok, population} <- select_parents(population, opts),
               {:ok, population} <- crossover(population, opts),
               {:ok, population} <- mutate(population, opts),
               {:ok, population} <- select_survivors(population, opts),
               {:ok, population} <- advance(population),
               {:ok, population} <- evaluate(population),
               {:ok, population} <- do_statistics(population) do
            cycle(population, opts)
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
      @spec select_parents(Population.t(), Keyword.t()) ::
              {:ok, Population.t()} | {:error, String.t()}
      def select_parents(population, opts \\ []) do
        selection_type = Keyword.get(opts, :selection_type, :natural)
        crossover_rate = Keyword.get(opts, :crossover_rate, 0.75)

        case selection_type do
          :natural ->
            do_parent_selection(population, crossover_rate, &Selection.natural/2, [])

          :worst ->
            do_parent_selection(population, crossover_rate, &Selection.worst/2, [])

          :random ->
            do_parent_selection(population, crossover_rate, &Selection.random/2, [])

          :roulette ->
            do_parent_selection(population, crossover_rate, &Selection.roulette/2, [])

          :tournament ->
            tournsize = Keyword.get(opts, :tournsize, nil)

            do_parent_selection(population, crossover_rate, &Selection.tournament/3, [
              tournsize
            ])

          :stochastic ->
            do_parent_selection(
              population,
              crossover_rate,
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
      def crossover(population, opts \\ []) do
        crossover_type = Keyword.get(opts, :crossover_type, :single_point)

        case crossover_type do
          :single_point ->
            do_crossover(population, &Crossover.single_point/2, [])

          :two_point ->
            do_crossover(population, &Crossover.two_point/2, [])

          :uniform ->
            uniform_crossover_rate = Keyword.get(opts, :uniform_crossover_rate, nil)
            do_crossover(population, &Crossover.uniform/3, [uniform_crossover_rate])

          :blend ->
            alpha = Keyword.get(opts, :blend_alpha, nil)
            do_crossover(population, &Crossover.blend/3, [alpha])

          :simulated_binary ->
            eta = Keyword.get(opts, :simulated_binary_eta, nil)
            do_crossover(population, &Crossover.simulated_binary/3, [eta])

          :messy_single_point ->
            do_crossover(population, &Crossover.messy_single_point/2, [])

          :davis_order ->
            do_crossover(population, &Crossover.davis_order/2, [])

          _ ->
            {:error, "Invalid Crossover Type."}
        end
      end

      @doc """
      Mutates a number of chromosomes.

      This function by default matches the "mutation_type" setting to the corresponding Mutation function. It returns an error if no match is found. If you want to customize this function, you can do so by overriding it. The default function works by mutating the `chromosomes` field of the Population struct.

      Returns `{:ok, Population}` or `{:error, "Invalid Mutation Type".}`.

      # Parameters
        - `population`: `Population` struct.
      """
      @spec mutate(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, String.t()}
      def mutate(population, opts \\ []) do
        mutation_type = Keyword.get(opts, :mutation_type, :scramble)
        radiation = Keyword.get(opts, :radiation, 0.5)
        mutation_rate = Keyword.get(opts, :mutation_rate, 0.05)

        case mutation_type do
          :bit_flip ->
            do_mutation(population, mutation_rate, &Mutation.bit_flip/2, [radiation])

          :scramble ->
            do_mutation(population, mutation_rate, &Mutation.scramble/2, [radiation])

          :invert ->
            do_mutation(population, mutation_rate, &Mutation.invert/2, [radiation])

          :uniform_integer ->
            uniform_integer_min = Keyword.get(opts, :uniform_integer_min, nil)
            uniform_integer_max = Keyword.get(opts, :uniform_integer_max, nil)

            do_mutation(population, mutation_rate, &Mutation.uniform_integer/4, [
              radiation,
              uniform_integer_min,
              uniform_integer_max
            ])

          :gaussian ->
            do_mutation(population, mutation_rate, &Mutation.gaussian/2, [radiation])

          :polynomial_bounded ->
            polynomial_bounded_min = Keyword.get(opts, :polynomial_bounded_min, nil)
            polynomial_bounded_max = Keyword.get(opts, :polynomial_bounded_max, nil)
            polynomial_bounded_eta = Keyword.get(opts, :polynomial_bounded_eta, nil)

            do_mutation(population, mutation_rate, &Mutation.polynomial_bounded/5, [
              radiation,
              polynomial_bounded_eta,
              polynomial_bounded_min,
              polynomial_bounded_max
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
      @spec select_survivors(Population.t(), Keyword.t()) ::
              {:ok, Population.t()} | {:error, String.t()}
      def select_survivors(population, opts \\ []) do
        selection_type = Keyword.get(opts, :selection_type, :natural)

        case selection_type do
          :natural ->
            do_survivor_selection(population, &Selection.natural/2, [])

          :worst ->
            do_survivor_selection(population, &Selection.worst/2, [])

          :random ->
            do_survivor_selection(population, &Selection.random/2, [])

          :roulette ->
            do_survivor_selection(population, &Selection.roulette/2, [])

          :tournament ->
            tournsize = Keyword.get(opts, :tournsize, nil)
            do_survivor_selection(population, &Selection.tournament/3, [tournsize])

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
      @spec advance(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def advance(population, _opts \\ []) do
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

      # Parameters

        - `opts`: Configuration options.
      """
      @spec run(Keyword.t()) :: Population.t()
      def run(opts \\ []) do
        Text.init()

        with {:ok, population} <- seed(opts),
             {:ok, population} <- evaluate(population, opts),
             {:ok, population} <- cycle(population, opts) do
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
      def benchmark(opts \\ []) do
        IO.write("Benchmarking your algorith. This may take awhile...\n")
        {:ok, init_pop} = seed(opts)
        {:ok, evaluated_pop} = evaluate(init_pop, opts)
        {:ok, parent_pop} = select_parents(evaluated_pop, opts)
        {:ok, child_pop} = crossover(parent_pop, opts)
        {:ok, mutated_pop} = mutate(child_pop, opts)
        {:ok, survivor_pop} = select_survivors(mutated_pop, opts)
        genes = encoding()
        c = %Chromosome{genes: genes, size: length(genes)}

        Benchee.run(%{
          "encoding/0" => fn -> encoding() end,
          "seed/0" => fn -> seed(opts) end,
          "fitness_function/1" => fn -> fitness_function(c) end,
          "terminate?/1" => fn -> terminate?(survivor_pop) end,
          "evaluate/1" => fn -> evaluate(init_pop) end,
          "select_parents/1" => fn -> select_parents(evaluated_pop, opts) end,
          "crossover/1" => fn -> crossover(parent_pop, opts) end,
          "mutate/1" => fn -> mutate(child_pop, opts) end,
          "select_survivors/1" => fn -> select_survivors(mutated_pop, opts) end
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

      defp do_mutation(population, rate, f, args) do
        u = rate

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

      defoverridable select_parents: 2,
                     crossover: 2,
                     mutate: 2,
                     select_survivors: 2,
                     seed: 1,
                     evaluate: 2,
                     advance: 2,
                     cycle: 2,
                     statistics: 0,
                     benchmark: 1
    end
  end

  defguard valid_rate?(rate) when is_float(rate) and rate >= 0.0 and rate <= 1.0
end
