defmodule Genex.Evolution do
  alias Genex.Operators.Crossover
  alias Genex.Operators.Mutation
  alias Genex.Operators.Reinsertion
  alias Genex.Operators.Selection
  alias Genex.Support.Genealogy
  alias Genex.Types.Population

  @moduledoc """
  Evolution behaviour definition for Evolutionary algorithms.

  There are 5 basic phases in the evolutionary algorithms we define with Genex:

  1. Evaluation (Competition)
  2. Selection (Parent Selection)
  3. Variation (Mutation, Crossover, Migration)
  4. Reinsertion (Survivor Selection)
  5. Transition
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
        if terminate?.(population) do
          {:ok, population}
        else
          with {:ok, population} <- selection(population, opts),
               {:ok, population} <- variation(population, opts),
               {:ok, population} <- evaluation(population, fitness_function, opts),
               {:ok, population} <- reinsertion(population, opts),
               {:ok, population} <- transition(population, opts) do
            Genex.Visualizers.Text.display_summary(population)
            evolve(population, terminate?, fitness_function, opts)
          else
            err -> raise err
          end
        end
      end

      @spec transition(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, any()}
      def transition(population, opts \\ []) do
        generation = population.generation + 1
        size = length(population.chromosomes)

        pop = %Population{
          population
          | size: size,
            generation: generation,
            children: nil,
            parents: nil,
            survivors: nil
        }

        {:ok, pop}
      end

      def match_selection(population, opts \\ []) do
        selection_type = Keyword.get(opts, :selection_type, :natural)
        lambda = Keyword.get(opts, :lambda, 0.75)

        case selection_type do
          :natural ->
            do_selection(population, lambda, &Selection.natural/2, [])

          :worst ->
            do_selection(population, lambda, &Selection.worst/2, [])

          :random ->
            do_selection(population, lambda, &Selection.random/2, [])

          :roulette ->
            do_selection(population, lambda, &Selection.roulette/2, [])

          :tournament ->
            # Ensure we raise a CLEAR error if tournsize isn't found.
            tournsize = Keyword.fetch!(opts, :tournsize)

            do_selection(population, lambda, &Selection.tournament/3, [
              tournsize
            ])

          :stochastic ->
            do_selection(
              population,
              lambda,
              &Selection.stochastic_universal_sampling/2,
              []
            )

          selection ->
            if is_function(selection),
              do: do_selection(population, lambda, selection, []),
              else: {:error, "Invalid Selection Type!"}
        end
      end

      def match_crossover(population, opts \\ []) do
        crossover_type = Keyword.get(opts, :crossover_type, :single_point)

        case crossover_type do
          :single_point ->
            do_crossover(population, &Crossover.single_point/2, [])

          :two_point ->
            do_crossover(population, &Crossover.two_point/2, [])

          :uniform ->
            uniform_crossover_rate = Keyword.fetch!(opts, :uniform_crossover_rate)
            do_crossover(population, &Crossover.uniform/3, [uniform_crossover_rate])

          :blend ->
            alpha = Keyword.fetch!(opts, :blend_alpha)
            do_crossover(population, &Crossover.blend/3, [alpha])

          :simulated_binary ->
            eta = Keyword.fetch!(opts, :simulated_binary_eta)
            do_crossover(population, &Crossover.simulated_binary/3, [eta])

          :messy_single_point ->
            do_crossover(population, &Crossover.messy_single_point/2, [])

          :davis_order ->
            do_crossover(population, &Crossover.davis_order/2, [])

          crossover ->
            if is_function(crossover),
              do: do_crossover(population, crossover, []),
              else: {:error, "Invalid Crossover Type!"}
        end
      end

      def match_mutation(population, opts \\ []) do
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
            uniform_integer_min = Keyword.fetch!(opts, :uniform_integer_min)
            uniform_integer_max = Keyword.fetch!(opts, :uniform_integer_max)

            do_mutation(population, mutation_rate, &Mutation.uniform_integer/4, [
              radiation,
              uniform_integer_min,
              uniform_integer_max
            ])

          :gaussian ->
            do_mutation(population, mutation_rate, &Mutation.gaussian/2, [radiation])

          :polynomial_bounded ->
            polynomial_bounded_min = Keyword.fetch!(opts, :polynomial_bounded_min)
            polynomial_bounded_max = Keyword.fetch!(opts, :polynomial_bounded_max)
            polynomial_bounded_eta = Keyword.fetch!(opts, :polynomial_bounded_eta)

            do_mutation(population, mutation_rate, &Mutation.polynomial_bounded/5, [
              radiation,
              polynomial_bounded_eta,
              polynomial_bounded_min,
              polynomial_bounded_max
            ])

          :none ->
            {:ok, population}

          mutate ->
            if is_function(mutate),
              do: do_mutation(population, mutation_rate, mutate, [radiation]),
              else: {:error, "Invalid Mutation Type!"}
        end
      end

      def match_reinsertion(population, opts \\ []) do
        reinsertion_type = Keyword.get(opts, :reinsertion_type, :elitist)

        case reinsertion_type do
          :elitist ->
            do_reinsertion(population, &Reinsertion.elitist/2, [])

          reinsertion ->
            if is_function(reinsertion), do: do_reinsertion(population, reinsertion, [])
        end
      end

      defp do_selection(population, lambda, f, args) do
        chromosomes = population.chromosomes
        n = if is_integer(lambda), do: lambda, else: floor(lambda * length(chromosomes))

        parents =
          f
          |> apply([chromosomes, n] ++ args)
          |> Enum.chunk_every(2, 2, :discard)
          |> Enum.map(fn f -> List.to_tuple(f) end)

        pop = %Population{population | parents: parents}
        {:ok, pop}
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

      defp do_reinsertion(population, f, args) do
        pool = population.chromosomes
        n = population.size - length(population.children)
        survivors = apply(f, [pool, n] ++ args)
        chromosomes = survivors ++ population.children
        pop = %Population{population | chromosomes: chromosomes}
        {:ok, pop}
      end
    end
  end
end
