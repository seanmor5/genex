defmodule Genex.Tools.Crossover do
  alias Genex.Chromosome
  alias Genex.Population
  @moduledoc """
  Crossover functions.
  """

  def single_point(population) do
    parents = population.parents
    chromosome_length = length(hd(population.chromosomes).genes)
    children = 
      parents
      |> Enum.map(fn f -> List.to_tuple(f) end)
      |> Enum.map(
          fn {p1, p2} ->
            point = :rand.uniform(chromosome_length)
            new_genes = Enum.slice(p1.genes, 0, point) ++ Enum.slice(p2.genes, point, chromosome_length)
            %Chromosome{genes: new_genes}
          end
        )
    pop = %Population{population | children: children}
    {:ok, pop}
  end

  def multi_point(population, rate), do: {:ok, population}
  def uniform(population, rate), do: {:ok, population}
  def davis_order(population, rate), do: {:ok, population}
  def whole_arithmetic(population, rate), do: {:ok, population}
end
