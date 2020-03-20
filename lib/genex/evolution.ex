defmodule Genex.Evolution do
  alias Genex.Tools.Crossover
  alias Genex.Tools.Selection
  alias Genex.Support.Genealogy
  alias Genex.Support.HallOfFame
  alias Genex.Types.Population

  @moduledoc """
  Evolution behaviour definition for Evolutionary algorithms.

  Evolutions begin with `init` after the population has been created. The purpose of `init` is to define metrics, initiate a geneaology tree, and create a hall of fame. `init` is like the "constructor" of the evolution.
  """

  @doc """
  Initialization of the evolution.
  """
  @callback init(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Evaluates `population` according to `fitness_fn`.
  """
  @callback evaluation(
              population :: Population.t(),
              fitness_fn :: (Chromosome.t() -> number()),
              opts :: Keyword.t()
            ) :: {:ok, Population.t()}

  @doc """
  Select parents for variation. Must populate `selected` field in `Population`.
  """
  @callback selection(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Perform variation such as Crossover, Mutation, and Migration.
  """
  @callback variation(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Recombine population.
  """
  @callback reinsertion(population :: Population.t(), opts :: Keyword.t()) ::
              {:ok, Population.t()}

  @doc """
  Perform housekeeping before next generation. Includes Gene Repair.
  """
  @callback transition(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  @doc """
  Termination of the evolution.
  """
  @callback termination(population :: Population.t(), opts :: Keyword.t()) :: Population.t()

  defmacro __using__(_) do
    quote do
      alias Genex.Types.Chromosome
      alias Genex.Types.Population
      @behaviour Genex.Evolution

      @spec init(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def init(population, opts \\ []) do
        visualizer = Keyword.get(opts, :visualizer, Genex.Visualizer.Text)
        visualizer.init(opts)
        history = Genealogy.init()
        HallOfFame.init()
        {:ok, %Population{population | history: history}}
      end

      @spec evolve(
              Population.t(),
              (Population.t() -> boolean()),
              (Chromosome.t() -> number()),
              Keyword.t()
            ) :: Population.t()
      def evolve(population, terminate?, fitness_function, opts \\ []) do
        visualizer = Keyword.get(opts, :visualizer, Genex.Visualizer.Text)
        # Check if the population meets termination criteria
        if terminate?.(population) do
          {:ok, population}
        else
          with {:ok, population} <- selection(population, opts),
               {:ok, population} <- variation(population, opts),
               {:ok, population} <- reinsertion(population, opts),
               {:ok, population} <- transition(population, opts),
               {:ok, population} <- evaluation(population, fitness_function, opts) do
            visualizer.display(population, opts)
            evolve(population, terminate?, fitness_function, opts)
          else
            err -> raise err
          end
        end
      end

      @spec evaluation(Population.t(), (Chromosome.t() -> number()), Keyword.t()) ::
              {:ok, Population.t()}
      def evaluation(population, func, opts \\ []) do
        chromosomes =
          population.chromosomes
          |> Enum.map(fn c -> %Chromosome{c | fitness: func.(c)} end)
          |> Enum.sort_by(& &1.fitness, &>=/2)

        strongest = hd(chromosomes)
        max_fitness = strongest.fitness

        pop = %Population{
          population
          | chromosomes: chromosomes,
            strongest: strongest,
            max_fitness: max_fitness
        }

        {:ok, pop}
      end

      @spec selection(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def selection(population, opts \\ []) do
        strategy = Keyword.get(opts, :selection_type, Selection.natural())
        rate = Keyword.get(opts, :selection_rate, 0.8)
        do_selection(population, strategy, rate)
      end

      @spec crossover(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def crossover(population, opts \\ []) do
        strategy = Keyword.get(opts, :crossover_type, Crossover.single_point())
        do_crossover(population, strategy)
      end

      @spec mutation(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def mutation(population, opts \\ []) do
        strategy = Keyword.get(opts, :mutation_type, :none)
        rate = Keyword.get(opts, :mutation_rate, 0.05)
        do_mutation(population, strategy, rate)
      end

      @spec reinsertion(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def reinsertion(population, opts \\ []) do
        selection_rate = Keyword.get(opts, :selection_rate, 0.8)
        survival_rate = Keyword.get(opts, :survival_rate, Float.round(1.0 - selection_rate, 1))
        strategy = Keyword.get(opts, :survival_type, :natural)

        survivors =
          case strategy do
            {_} -> do_survivor_selection(population, strategy, survival_rate)
            {_, _} -> do_survivor_selection(population, strategy, survival_rate)
            {_, _, _} -> do_survivor_selection(population, strategy, survival_rate)
            {_, _, _, _} -> do_survivor_selection(population, strategy, survival_rate)
            _ -> do_survivor_selection(population, {strategy}, survival_rate)
          end

        new_chromosomes = population.children ++ survivors

        pop = %Population{
          population
          | size: length(new_chromosomes),
            chromosomes: new_chromosomes
        }

        {:ok, pop}
      end

      @spec transition(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, any()}
      def transition(population, opts \\ []) do
        generation = population.generation + 1
        size = length(population.chromosomes)
        chromosomes = do_update_ages(population.chromosomes)

        HallOfFame.add(population)

        pop = %Population{
          population
          | chromosomes: chromosomes,
            size: size,
            generation: generation,
            selected: nil,
            children: nil,
            survivors: nil
        }

        {:ok, pop}
      end

      @spec termination(Population.t(), Keyword.t()) :: Population.t()
      def termination(population, opts \\ []) do
        chromosomes =
          population.chromosomes
          |> Enum.sort_by(& &1.fitness, &>=/2)

        strongest = hd(chromosomes)

        max_fitness = strongest.fitness

        HallOfFame.add(population)

        %Population{
          population
          | chromosomes: chromosomes,
            strongest: strongest,
            max_fitness: max_fitness
        }
      end

      defp do_selection(population, strategy, rate) do
        chromosomes = population.chromosomes

        n =
          if is_function(rate) do
            floor(rate.(population) * population.size)
          else
            floor(rate * population.size)
          end

        selected = strategy.(chromosomes, n)

        pop = %Population{population | selected: selected}
        {:ok, pop}
      end

      defp do_crossover(population, :none), do: {:ok, population}

      defp do_crossover(population, strategy) do
        parents = population.selected

        starting_children =
          case population.children do
            nil -> []
            chd -> chd
          end

        {children, history} =
          parents
          |> Enum.chunk_every(2, 2, :discard)
          |> Enum.map(fn f -> List.to_tuple(f) end)
          |> Enum.reduce(
            {starting_children, population.history},
            fn {p1, p2}, {chd, his} ->
              {c1, c2} = strategy.(p1, p2)

              new_his =
                his
                |> Genealogy.update(c1, p1, p2)
                |> Genealogy.update(c2, p1, p2)

              {[c1 | [c2 | chd]], new_his}
            end
          )

        pop = %Population{population | children: children, history: history, selected: nil}
        {:ok, pop}
      end

      defp do_mutation(population, :none, rate), do: {:ok, population}

      defp do_mutation(population, strategy, rate) do
        u = if is_function(rate), do: rate.(population), else: rate

        mutate =
          case population.selected do
            nil -> population.chromosomes
            _ -> population.selected
          end

        {mutants, new_his} =
          mutate
          |> Enum.reduce(
            {[], population.history},
            fn c, {mut, his} ->
              if :rand.uniform() < u do
                mutant = strategy.(c)
                new_his = Genealogy.update(his, c, mutant)
                {[mutant | mut], new_his}
              else
                {[c | mut], his}
              end
            end
          )

        pop =
          case population.selected do
            nil -> %Population{population | chromosomes: mutants, history: new_his}
            _ -> %Population{population | children: mutants, selected: nil, history: new_his}
          end

        {:ok, pop}
      end

      defp do_survivor_selection(population, strategy, rate) do
        chromosomes = population.chromosomes

        n =
          if is_function(rate) do
            floor(rate.(population) * length(chromosomes))
          else
            floor(rate * length(chromosomes))
          end

        survivors =
          if is_function(strategy) do
            strategy.(chromosomes, n)
          else
            [f | args] = Tuple.to_list(strategy)
            apply(Selection, f, [chromosomes, n] ++ args)
          end

        survivors
      end

      defp do_update_ages(chromosomes) do
        chromosomes
        |> Enum.map(fn c -> %Chromosome{c | age: c.age + 1} end)
      end

      defp do_gene_repair, do: :ok

      defoverridable init: 2,
                     transition: 2,
                     evaluation: 3,
                     crossover: 2,
                     mutation: 2,
                     selection: 2,
                     evolve: 4,
                     termination: 2
    end
  end
end
