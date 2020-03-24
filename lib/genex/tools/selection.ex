defmodule Genex.Tools.Selection do
  @moduledoc """
  Implementation of several popular selection methods.

  Selection occurs in two stages in Genex: parent selection and survivor selection. Parent Selection dictates which chromosomes are to be reserved for crossover according to some crossover rate. In this stage, a number of chromosomes are selected and paired off in 2-tuples in the order they are selected. Future versions of Genex will provide more advanced methods of parent selection.

  Survivor Selection occurs last in the GA cycle. As of this version of Genex, the survivor rate is always equal to `1 - CR` where CR is the crossover rate. Future versions will support more advanced survivor selection, including the ability to fluctuate the population according to some operators.
  """

  @doc """
  Natural selection of some number of chromosomes.

  This will select the `n` best (fittest) chromosomes.

  Returns `Enum.t`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
  """
  @spec natural(Enum.t(), integer()) :: Enum.t()
  def natural(chromosomes, n) do
    chromosomes
    |> Enum.take(n)
  end

  @doc false
  def natural, do: &natural(&1, &2)

  @doc """
  Worst selection of some number of chromosomes.

  This will select the `n` worst (least fit) chromosomes.

  Returns `Enum.t`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
  """
  @spec worst(Enum.t(), integer()) :: Enum.t()
  def worst(chromosomes, n) do
    chromosomes
    |> Enum.reverse()
    |> Enum.take(n)
  end

  @doc false
  def worst, do: &worst(&1, &2)

  @doc """
  Random selection of some number of chromosomes.

  This will select `n` random chromosomes.

  Returns `Enum.t`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
  """
  @spec random(Enum.t(), integer) :: Enum.t()
  def random(chromosomes, n) do
    chromosomes
    |> Enum.take_random(n)
  end

  @doc false
  def random, do: &random(&1, &2)

  @doc """
  Tournament selection of some number of chromosomes.

  This will select `n` chromosomes from tournaments of size `k`. We randomly select `k` chromosomes from the population and choose the max to be in the tournament.

  Returns `Enum.t()`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
    - `tournsize`: The size of the tournament to run.
  """
  @spec tournament(Enum.t(), integer(), integer()) :: Enum.t()
  def tournament(chromosomes, n, tournsize) do
    0..(n - 1)
    |> Enum.map(fn _ ->
      chromosomes
      |> Enum.take_random(tournsize)
      |> Enum.max_by(& &1.fitness)
    end)
  end

  @doc false
  def tournament(tournsize: tournsize), do: &tournament(&1, &2, tournsize)

  @doc """
  Roulette selection of some number of chromosomes.

  This will select `n` chromosomes using a "roulette" wheel where the probability of a chromosome being selected is proportional to it's fitness.

  Returns `Enum.t()`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
  """
  @spec roulette(Enum.t(), integer()) :: Enum.t()
  def roulette(chromosomes, n) do
    sum_fitness =
      chromosomes
      |> Enum.reduce(0, fn x, acc -> acc + x.fitness end)

    0..(n - 1)
    |> Enum.map(fn _ ->
      u = :rand.uniform() * sum_fitness

      chromosomes
      |> Enum.reduce_while(
        0,
        fn x, sum ->
          if x.fitness + sum > u do
            {:halt, x}
          else
            {:cont, x.fitness + sum}
          end
        end
      )
    end)
  end

  @doc false
  def roulette, do: &roulette(&1, &2)

  @doc """
  Stochastic Universal Sampling of chromosomes.

  This will sample all of the chromosomes without bias, choosing them at evenly spaced intervals.

  Returns `Enum.t()`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromomsomes to select.
  """
  @spec stochastic_universal_sampling(Enum.t(), integer()) :: Enum.t()
  def stochastic_universal_sampling(chromosomes, n) do
    sum_fitness =
      chromosomes
      |> Enum.reduce(0, fn x, acc -> acc + x.fitness end)

    p = sum_fitness / n
    start = p * :rand.uniform()
    pointers = for i <- 0..(n - 1), do: start + i * p

    pointers
    |> Enum.map(fn x ->
      chromosomes
      |> Enum.reduce_while(
        0,
        fn y, sum ->
          if y.fitness + sum >= x do
            {:halt, y}
          else
            {:cont, y.fitness + sum}
          end
        end
      )
    end)
  end

  @doc false
  def stochastic_universal_sampling, do: &stochastic_universal_sampling(&1, &2)

  @doc false
  def boltzmann, do: :ok

  @doc false
  def rank, do: :ok

  @doc false
  def double_tournament, do: :ok

  @doc false
  def tournament_dcd, do: :ok

  @doc false
  def lexicase, do: :ok

  @doc false
  def epsilon_lexicase, do: :ok

  @doc false
  def automatic_epsilon_lexicase, do: :ok
end
