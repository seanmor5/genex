defmodule Genex.Population do
  alias __MODULE__, as: Population
  import Genex.Chromosome
  @moduledoc """
  A `Population` is a collection of `Chromosomes`. 

  The `Population` represents the pool of solutions you are trying to optimize. Ideally, you persist the 'fittest' features from generation to generation until you converge on a solution.
  """

  @type t :: %Population{
    chromosomes: Enum.t(),
    generation: integer(),
    max_fitness: number(),
    parents: Enum.t() | nil,
    survivors: Enum.t() | nil,
    children: Enum.t() | nil
  }

  @enforce_keys [:chromosomes]
  defstruct [:chromosomes, generation: 0, max_fitness: 0, parents: nil, survivors: nil, children: nil]

  @doc """
  Sort the population by fitness.
  """
  def sort(population) do
    chromosomes = population.chromosomes
    gen = population.generation
    max_fit = population.max_fitness
    sorted_chromosomes = Enum.reverse(Enum.sort_by(chromosomes, &get_fitness/1))
    %Population{population | chromosomes: sorted_chromosomes}
  end
end
