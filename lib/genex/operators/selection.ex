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

  @doc """
  Roulette selection of some number of chromosomes.

  This will select `n` chromosomes using `k`spins of a roulette wheel.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def roulette(population, rate), do: {:ok, population}

  @doc """
  Tournament selection of some number of chromosomes.

  This will select `n` chromosomes from a pool of size `k` who perform the best in randomly chosen tournament.

  Returns `Population`.

  # Parameters
    - `population`: `Population` struct.
    - `type`: `:parents` or `:survivors`.
    - `rate`: `Float` representing survival rate or crossover rate.
  """
  def tournament(population, rate), do: {:ok, population}
  def stochastic(population, rate), do: {:ok, population}
end
