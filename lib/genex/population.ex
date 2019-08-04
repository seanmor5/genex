defmodule Genex.Population do
  import Genex.Chromosome
  @moduledoc """
  A `Population` is a collection of `Chromosomes`.

  The `Population` represents the pool of solutions you are trying to optimize. Ideally, you persist the 'fittest' features from generation to generation until you converge on a solution.
  """

  @type t :: %__MODULE__{
    chromosomes: Enum.t(),
    generation: integer(),
    max_fitness: number(),
    parents: Enum.t() | nil,
    survivors: Enum.t() | nil,
    children: Enum.t() | nil,
    size: integer()
  }

  @enforce_keys [:chromosomes]
  defstruct [
    :chromosomes,
    generation: 0,
    max_fitness: 0,
    parents: nil,
    survivors: nil,
    children: nil,
    size: 0,
    strongest: nil
  ]

  @doc """
  Sort the population by fitness.
  """
  def sort(population) do
    sorted_chromosomes =
      population.chromosomes
      |> Enum.sort_by(&get_fitness/1)
      |> Enum.reverse()
    %__MODULE__{population | chromosomes: sorted_chromosomes, strongest: hd(sorted_chromosomes)}
  end
end
