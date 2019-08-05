defmodule Genex.Operators.Selection do
  alias Genex.Population

  @moduledoc """
  Implementation of several popular selection methods.

  Selection occurs in two stages in Genex: parent selection and survivor selection. Parent Selection dictates which chromosomes are to be reserved for crossover according to some crossover rate. In this stage, a number of chromosomes are selected and paired off in 2-tuples in the order they are selected. Future versions of Genex will provide more advanced methods of parent selection.

  Survivor Selection occurs last in the GA cycle. As of this version of Genex, the survivor rate is always equal to `1 - CR` where CR is the crossover rate. Future versions will support more advanced survivor selection, including the ability to fluctuate the population according to some operators.
  """

  @doc """
  Natural selection of some number of chromosomes.

  This will select the `n` best (fittest) chromosomes.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def natural(population, rate) do
    chromosomes = population.chromosomes
    n = floor(rate * length(chromosomes))
    parents =
      chromosomes
      |> Enum.take(n)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn f -> List.to_tuple(f) end)
    pop = %Population{population | parents: parents}
    {:ok, pop}
  end
  def natural(population) do
    chromosomes = population.chromosomes
    n = length(population.chromosomes) - length(population.children)
    survivors =
      chromosomes
      |> Enum.take(n)
    pop = %Population{population | survivors: survivors}
    {:ok, pop}
  end

  @doc """
  Worst selection of some number of chromosomes.

  This will select the `n` worst (least fit) chromosomes.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def worst(population, rate) do
    chromosomes = population.chromosomes
    n = floor(rate * length(chromosomes))
    parents =
      chromosomes
      |> Enum.reverse
      |> Enum.take(n)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn f -> List.to_tuple(f) end)
    pop = %Population{population | parents: parents}
    {:ok, pop}
  end
  def worst(population) do
    chromosomes = population.chromosomes
    n = length(population.chromosomes) - length(population.children)
    survivors =
      chromosomes
      |> Enum.reverse
      |> Enum.take(n)
    pop = %Population{population | survivors: survivors}
    {:ok, pop}
  end

  @doc """
  Random selection of some number of chromosomes.

  This will select `n` random chromosomes.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def random(population, rate) do
    chromosomes = population.chromosomes
    n = floor(rate * length(chromosomes))
    parents =
      chromosomes
      |> Enum.take_random(n)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn f -> List.to_tuple(f) end)
    pop = %Population{population | parents: parents}
    {:ok, pop}
  end
  def random(population) do
    chromosomes = population.chromosomes
    n = length(population.chromosomes) - length(population.children)
    survivors =
      chromosomes
      |> Enum.take_random(n)
    pop = %Population{population | survivors: survivors}
    {:ok, pop}
  end
end
