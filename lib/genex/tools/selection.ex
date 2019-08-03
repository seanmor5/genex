defmodule Genex.Tools.Selection do
  alias Genex.Population

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
  def natural(population, _, rate), do: {:error, "Invalid Selection Type"}

  def worst(population, stage, rate), do: {:ok, population}
  def random(population, stage, rate), do: {:ok, population}
  def roulette(population, stage, rate), do: {:ok, population}
  def tournament(population, stage, rate), do: {:ok, population}
  def stochastic(population, stage, rate), do: {:ok, population}
end
