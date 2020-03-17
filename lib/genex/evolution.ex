defmodule Genex.Evolution do
  alias Genex.Tools.Crossover
  alias Genex.Tools.Mutation
  alias Genex.Tools.Reinsertion
  alias Genex.Tools.Selection
  alias Genex.Support.Genealogy
  alias Genex.Support.HallOfFame
  alias Genex.Types.Population

  @moduledoc """
  Evolution behaviour definition for Evolutionary algorithms.

  There are 5 basic phases in the evolutionary algorithms we define with Genex:

  1. Evaluation (Competition)
  2. Selection (Parent Selection)
  3. Variation (Mutation, Crossover, Migration)
  4. Reinsertion (Survivor Selection)
  5. Transition

  Each step performs a transformation on the population struct and returns with `{:ok, Population}` or with an error and a reason.
  """
  @callback evaluation(
              population :: Population.t(),
              (Chromosome.t() -> number()),
              opts :: Keyword.t()
            ) :: {:ok, Population.t()}

  @callback selection(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  @callback variation(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  @callback reinsertion(population :: Population.t(), opts :: Keyword.t()) ::
              {:ok, Population.t()}

  @doc """
  Performs necessary operations for transitioning between generations.
  """
  @callback transition(population :: Population.t(), opts :: Keyword.t()) :: {:ok, Population.t()}

  defmacro __using__(_) do
    quote do
      alias Genex.Types.Chromosome
      alias Genex.Types.Population
      @behaviour Genex.Evolution

      @spec evolve(
              Population.t(),
              (Population.t() -> boolean()),
              (Chromosome.t() -> number()),
              Keyword.t()
            ) :: Population.t()
      def evolve(population, terminate?, fitness_function, opts \\ []) do
        visualizer = Keyword.get(opts, :visualizer, Genex.Visualizers.Text)

        if terminate?.(population) do
          {:ok, population}
        else
          with {:ok, population} <- evaluation(population, fitness_function, opts),
               {:ok, population} <- selection(population, opts),
               {:ok, population} <- variation(population, opts),
               {:ok, population} <- reinsertion(population, opts),
               {:ok, population} <- transition(population, opts) do
            visualizer.display(population)
            evolve(population, terminate?, fitness_function, opts)
          else
            err -> raise err
          end
        end
      end

      @spec evaluation(Population.t(), (Chromosome.t() -> number()), Keyword.t()) ::
              {:ok, Population.t()}
      def evaluation(population, func, opts \\ []) do
        minimize = Keyword.get(opts, :minimize?, false)

        chromosomes =
          population.chromosomes
          |> Enum.map(fn c -> %Chromosome{c | fitness: func.(c)} end)

        pop = Population.sort(%Population{population | chromosomes: chromosomes}, minimize)
        {:ok, pop}
      end

      @spec selection(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def selection(population, opts \\ []) do
        strategy = Keyword.get(opts, :selection_type, :natural)
        rate = Keyword.get(opts, :selection_rate, 0.8)

        case strategy do
          [_] -> do_selection(population, strategy, rate)
          _ -> do_selection(population, [strategy], rate)
        end
      end

      @spec crossover(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def crossover(population, opts \\ []) do
        strategy = Keyword.get(opts, :crossover_type, :single_point)

        case strategy do
          [_] -> do_crossover(population, strategy)
          _ -> do_crossover(population, [strategy])
        end
      end

      @spec mutation(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def mutation(population, opts \\ []) do
        strategy = Keyword.get(opts, :mutation_type, :none)
        rate = Keyword.get(opts, :mutation_rate, 0.05)

        case strategy do
          [_] -> do_mutation(population, strategy, rate)
          _ -> do_mutation(population, [strategy], rate)
        end
      end

      @spec reinsertion(Population.t(), Keyword.t()) :: {:ok, Population.t()}
      def reinsertion(population, opts \\ []) do
        strategy = Keyword.get(opts, :survival_type, :elitist)
        selection_rate = Keyword.get(opts, :selection_rate, 0.8)
        survival_rate = Keyword.get(opts, :survival_rate, Float.round(1.0 - selection_rate, 1))

        survivors =
          case strategy do
            [_] -> do_survivor_selection(population, strategy, survival_rate)
            _ -> do_survivor_selection(population, [strategy], survival_rate)
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

        HallOfFame.add(population)

        pop = %Population{
          population
          | size: size,
            generation: generation,
            selected: nil,
            children: nil,
            survivors: nil
        }

        {:ok, pop}
      end

      defp do_selection(population, strategy, rate) do
        chromosomes = population.chromosomes

        n =
          if is_function(rate) do
            floor(rate.(population) * population.size)
          else
            floor(rate * population.size)
          end

        [f | args] = strategy

        selected =
          if is_function(f) do
            apply(f, [chromosomes, n])
          else
            apply(Genex.Tools.Selection, f, [chromosomes, n] ++ args)
          end

        pop = %Population{population | selected: selected}
        {:ok, pop}
      end

      defp do_crossover(population, [:none | _]), do: {:ok, population}

      defp do_crossover(population, strategy) do
        parents = population.selected
        [f | args] = strategy

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
              {c1, c2} =
                if is_function(strategy) do
                  apply(strategy, [p1, p2])
                else
                  apply(Genex.Tools.Crossover, f, [p1, p2] ++ args)
                end

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

      defp do_mutation(population, [:none | _], rate), do: {:ok, population}

      defp do_mutation(population, strategy, rate) do
        u = if is_function(rate), do: rate.(population), else: rate

        mutate =
          case population.selected do
            nil -> population.chromosomes
            _ -> population.selected
          end

        [f | args] = strategy

        {mutants, new_his} =
          mutate
          |> Enum.reduce(
            {[], population.history},
            fn c, {mut, his} ->
              if :rand.uniform() < u do
                mutant =
                  if is_function(f) do
                    apply(f, [c] ++ args)
                  else
                    apply(Genex.Tools.Mutation, f, [c] ++ args)
                  end

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

        [f | args] = strategy

        survivors =
          if is_function(f) do
            apply(f, [chromosomes, n] ++ args)
          else
            apply(Genex.Tools.Reinsertion, f, [chromosomes, n] ++ args)
          end

        survivors
      end

      defoverridable transition: 2,
                     evaluation: 3,
                     crossover: 2,
                     mutation: 2,
                     selection: 2,
                     evolve: 4
    end
  end
end
