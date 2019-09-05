defmodule Genex.Types.Population do
  alias Genex.Types.Chromosome

  @moduledoc """
  A collection of `Chromosomes`.

  The `Population` represents the pool of solutions you are trying to optimize. Ideally, you persist the 'fittest' features from generation to generation until you converge on a solution.

  The `Population` struct contains a number of useful fields that can be analyzed after the algorithm runs.
  """

  @type t :: %__MODULE__{
          chromosomes: Enum.t(),
          generation: integer(),
          max_fitness: number(),
          survivors: Enum.t() | nil,
          selected: Enum.t() | nil,
          children: Enum.t() | nil,
          size: integer(),
          strongest: Chromosome.t(),
          history: :digraph.graph(),
          statistics: Keyword.t()
        }

  @enforce_keys [:chromosomes]
  defstruct [
    :chromosomes,
    generation: 0,
    max_fitness: 0,
    survivors: nil,
    selected: nil,
    children: nil,
    size: 0,
    strongest: nil,
    history: nil,
    statistics: []
  ]

  @doc """
  Sort the population by fitness.

  Returns `%Population{}`.

  # Parameters

    - `population`- Population struct.
    - `minimize`- Flag for minimization.
  """
  def sort(population, false) do
    sorted_chromosomes =
      population.chromosomes
      |> Enum.sort_by(& &1.fitness)
      |> Enum.reverse()

    %__MODULE__{
      population
      | chromosomes: sorted_chromosomes,
        strongest: hd(sorted_chromosomes),
        max_fitness: hd(sorted_chromosomes).fitness
    }
  end

  def sort(population, true) do
    sorted_chromosomes =
      population.chromosomes
      |> Enum.sort_by(& &1.fitness)

    %__MODULE__{
      population
      | chromosomes: sorted_chromosomes,
        strongest: hd(sorted_chromosomes),
        max_fitness: hd(sorted_chromosomes).fitness
    }
  end
end
