defmodule Genex.Operators.Selection do
  alias Genex.Population

  @moduledoc """
  Selection functions.
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
  def natural(population, :parents, rate) do
    chromosomes = population.chromosomes
    n = floor(rate * length(chromosomes))
    parents =
      chromosomes
      |> Enum.take(n)
      |> Enum.chunk_every(2, 1, :discard)
    pop = %Population{population | parents: parents}
    {:ok, pop}
  end
  def natural(population, :survivors, _rate) do
    chromosomes = population.chromosomes
    n = length(population.chromosomes) - length(population.children)
    survivors =
      chromosomes
      |> Enum.take(n)
    pop = %Population{population | survivors: survivors}
    {:ok, pop}
  end
  def natural(_, _, _), do: {:error, "Invalid Selection Type"}

  @doc """
  Worst selection of some number of chromosomes.

  This will select the `n` worst (least fit) chromosomes.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def worst(population, :parents, rate) do
    chromosomes = population.chromosomes
    n = floor(rate * length(chromosomes))
    parents =
      chromosomes
      |> Enum.reverse
      |> Enum.take(n)
      |> Enum.chunk_every(2, 1, :discard)
    pop = %Population{population | parents: parents}
    {:ok, pop}
  end
  def worst(population, :survivors, _rate) do
    chromosomes = population.chromosomes
    n = length(population.chromosomes) - length(population.children)
    survivors =
      chromosomes
      |> Enum.reverse
      |> Enum.take(n)
    pop = %Population{population | survivors: survivors}
    {:ok, pop}
  end
  def worst(_, _, _), do: {:error, "Invalid Selection Type"}

  @doc """
  Random selection of some number of chromosomes.

  This will select `n` random chromosomes.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def random(population, :parents, rate) do
    chromosomes = population.chromosomes
    n = floor(rate * length(chromosomes))
    parents =
      chromosomes
      |> Enum.take_random(n)
      |> Enum.chunk_every(2, 1, :discard)
    pop = %Population{population | parents: parents}
    {:ok, pop}
  end
  def random(population, :survivors, _rate) do
    chromosomes = population.chromosomes
    n = length(population.chromosomes) - length(population.children)
    survivors =
      chromosomes
      |> Enum.take_random(n)
    pop = %Population{population | survivors: survivors}
    {:ok, pop}
  end
  def random(_, _, _), do: {:error, "Invalid Selection Type"}

  def roulette(population, stage, rate), do: {:ok, population}
  def tournament(population, stage, rate), do: {:ok, population}
  def stochastic(population, stage, rate), do: {:ok, population}
end
