defmodule Genex.Operators.Selection do
  alias Genex.Chromosome

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
  def natural(chromosomes, n) do
    chromosomes
    |> Enum.take(n)
  end

  @doc """
  Worst selection of some number of chromosomes.

  This will select the `n` worst (least fit) chromosomes.

  Returns `Enum.t`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
  """
  def worst(chromosomes, n) do
    chromosomes
    |> Enum.reverse
    |> Enum.take(n)
  end

  @doc """
  Random selection of some number of chromosomes.

  This will select `n` random chromosomes.

  Returns `Enum.t`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
  """
  def random(chromosomes, n) do
    chromosomes
    |> Enum.take_random(n)
  end

  @doc """
  Tournament selection of some number of chromosomes.

  This will select `n` chromosomes from tournaments of size `k`. We randomly select `k` chromosomes from the population and choose the max to be in the tournament.

  Returns `Enum.t`.

  # Parameters
    - `chromosomes`: `Enum` of `Chromosomes`.
    - `n`: Number of chromosomes to select.
    - `tournsize`: The size of the tournament to run.
  """
  def tournament(chromosomes, n, tournsize) do
    0..n
    |> Enum.map(
        fn _ ->
          chromosomes
          |> Enum.take_random(tournsize)
          |> Enum.max_by(&Genex.Chromosome.get_fitness/1)
        end
      )
  end
end
